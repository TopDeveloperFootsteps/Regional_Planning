import pool from "../db";
import { Router, Request, Response } from 'express';
const router = Router();

// Middleware to validate incoming requests

router.post('/', async (req: Request, res: Response) => {
    const { icdCode, systemOfCare, careSettingTable } = req.body;

    try {
        const match = icdCode.replace(/['"]/g, '').trim().match(/^([A-Z]\d+)/i);
        if (!match) {
            return res.status(400).json({ error: 'Invalid ICD code format' });
        }
        const icdPrefix = match[1].toUpperCase();

        const result = await pool.query(
            `SELECT service, confidence, mapping_logic FROM ${careSettingTable} 
             WHERE icd_code ILIKE $1 AND systems_of_care = $2 LIMIT 1`,
            [`${icdPrefix}%`, systemOfCare]
        );

        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).json({ error: 'No mapping found' });
        }
    } catch (error) {
        console.error('Error fetching mapping:', error);
        res.status(500).json({ error: 'Failed to fetch mapping' });
    }
});

// Endpoint to fetch mapping for bulk upload
router.post('/batch', async (req: Request, res: Response) => {
    const { batch, careSettingTable } = req.body;

    try {
        const promises = batch.map(async (row: any) => {
            const match = row['ICD Code'].replace(/['"]/g, '').trim().match(/^([A-Z]\d+)/i);
            if (!match) {
                return { ...row, Service: null, Confidence: null, 'Mapping Logic': null };
            }
            const icdPrefix = match[1].toUpperCase();

            const result = await pool.query(
                `SELECT service, confidence, mapping_logic FROM ${careSettingTable} 
                 WHERE icd_code ILIKE $1 AND systems_of_care = $2 LIMIT 1`,
                [`${icdPrefix}%`, row['Systems of Care']]
            );

            if (result.rows.length > 0) {
                row.Service = result.rows[0].service;
                row.Confidence = result.rows[0].confidence;
                row['Mapping Logic'] = result.rows[0].mapping_logic;
            }
            return row;
        });

        const processedBatch = await Promise.all(promises);
        res.json(processedBatch);
    } catch (error) {
        console.error('Error processing batch:', error);
        res.status(500).json({ error: 'Failed to process batch' });
    }
});

export default router;
