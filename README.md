# Regional Planning Project

## Getting Started
This guide will help you set up and run the **Regional Planning** project on your local machine.

## Prerequisites
Make sure you have the following installed on your system before proceeding:

- **PostgreSQL** (Recommended: Version 17)
- **Node.js** (Latest LTS version recommended)
- **Git**

---
## Step 1: Install PostgreSQL

Download and install PostgreSQL from the official site: [PostgreSQL Download](https://www.postgresql.org/download/)

Ensure that you set up a PostgreSQL user and remember the username and password for later steps.

---
## Step 2: Clone the Repository

Use Git to clone the project repository from GitHub:

```sh
 git clone https://github.com/TopDeveloperFootsteps/Regional_Planning.git
```

Navigate to the project folder:

```sh
 cd Regional_Planning
```

---
## Step 3: Create a New Database

1. Open **pgAdmin** or your preferred PostgreSQL management tool.
2. Navigate to `Servers > PostgreSQL 17 > Databases`.
3. Right-click on `Databases`, select **Create Database**.
4. Enter a database name (e.g., `regional_planning`) and click **Save**.

---
## Step 4: Setting Up the Database

You need to execute the schema and data scripts to set up the database.

1. Open **pgAdmin** and right-click on your newly created database.
2. Select **Query Tool**.
3. Execute the schema script:
   - Open `schema.sql` from the `/db` folder.
   - Copy-paste its contents into the query editor and run it.
4. Execute the data script:
   - Open `data.sql` from the `/db` folder.
   - Copy-paste its contents into the query editor and run it.

Your database is now fully set up!

---
## Step 5: Configure the Environment Variables

Navigate to the `backend` folder:

Create a new **.env** file in the `backend` directory and configure it as follows:

```sh
DB_USER=your_username  # Default: postgres
DB_HOST=localhost
DB_NAME=your_database_name
DB_PASSWORD=your_password
DB_PORT=5432
```

Replace `your_username`, `your_database_name`, and `your_password` with the actual values.

---
## Step 6: Install Dependencies

### 1. Install Node.js (if not already installed)
Download and install Node.js from: [Node.js Official Website](https://nodejs.org/)

### 2. Install Required Packages
Open two terminal windows, one for the **backend** and one for the **frontend**.

#### Backend Setup
Navigate to the `backend` directory and install dependencies:

```sh
 cd backend
 npm install
```

#### Frontend Setup
Navigate to the `frontend` directory and install dependencies:

```sh
 npm install
```

---
## Step 7: Run the Project

### 1. Start the Backend Server
In the `backend` folder, run:

```sh
 npm start
```

### 2. Start the Frontend Server
In the `frontend` folder, run:

```sh
 npm run dev
```

Your project should now be running successfully!

---
## Troubleshooting
If you encounter any issues:
- Ensure PostgreSQL is running.
- Verify that your `.env` file is correctly set up.
- Check if all dependencies are properly installed.

For further assistance, check the project documentation or contact the repository maintainers.

---

