const express = require("express");
const mysql = require("mysql2/promise");

const app = express();

const PORT =
    process.env.PORT || 3000;

app.use(express.json());


const pool =
    mysql.createPool({

        host:
            process.env.DB_HOST,

        user:
            process.env.DB_USER,

        password:
            process.env.DB_PASSWORD,

        database:
            process.env.DB_NAME,

        port:
            Number(
                process.env.DB_PORT || 3306
            ),

        waitForConnections:
            true,

        connectionLimit:
            10,

        queueLimit:
            0

    });


async function initializeDatabase() {

    for (
        let attempt = 1;
        attempt <= 30;
        attempt++
    ) {

        try {

            const connection =
                await pool.getConnection();


            await connection.query(`

                CREATE TABLE IF NOT EXISTS employees (

                    id INT AUTO_INCREMENT PRIMARY KEY,

                    name VARCHAR(100) NOT NULL,

                    email VARCHAR(150) NOT NULL,

                    department VARCHAR(100) NOT NULL,

                    created_at
                    TIMESTAMP DEFAULT CURRENT_TIMESTAMP

                )

            `);


            connection.release();

            console.log(
                "Database initialized successfully"
            );

            return;

        }
        catch (error) {

            console.log(
                `Database connection attempt ${attempt} failed`
            );


            if (attempt === 30) {

                throw error;

            }


            await new Promise(
                resolve =>
                    setTimeout(resolve, 5000)
            );

        }
    }
}


// Health check
app.get(
    "/health",
    async (req, res) => {

        try {

            await pool.query(
                "SELECT 1"
            );


            res.status(200).json({

                status: "ok"

            });

        }
        catch (error) {

            res.status(503).json({

                status:
                    "database unavailable"

            });

        }

    }
);


// Get all employees
app.get(
    "/employees",
    async (req, res) => {

        try {

            const [rows] =
                await pool.query(`

                    SELECT
                        id,
                        name,
                        email,
                        department

                    FROM employees

                    ORDER BY id DESC

                `);


            res.json(rows);

        }
        catch (error) {

            console.error(error);

            res.status(500).json({

                error:
                    "Unable to retrieve employees"

            });

        }
    }
);


// Add employee
app.post(
    "/employees",
    async (req, res) => {

        const {
            name,
            email,
            department
        } = req.body;


        if (
            !name ||
            !email ||
            !department
        ) {

            return res.status(400).json({

                error:
                    "Name, email and department are required"

            });

        }


        try {

            const [result] =
                await pool.execute(

                    `

                    INSERT INTO employees
                    (
                        name,
                        email,
                        department
                    )

                    VALUES (?, ?, ?)

                    `,

                    [
                        name,
                        email,
                        department
                    ]

                );


            res.status(201).json({

                id:
                    result.insertId,

                name,

                email,

                department

            });

        }
        catch (error) {

            console.error(error);

            res.status(500).json({

                error:
                    "Unable to create employee"

            });

        }
    }
);


// Delete employee
app.delete(
    "/employees/:id",
    async (req, res) => {

        const id =
            req.params.id;


        try {

            await pool.execute(

                "DELETE FROM employees WHERE id = ?",

                [id]

            );


            res.json({

                message:
                    "Employee deleted successfully"

            });

        }
        catch (error) {

            console.error(error);

            res.status(500).json({

                error:
                    "Unable to delete employee"

            });

        }
    }
);


initializeDatabase()

    .then(() => {

        app.listen(
            PORT,
            "0.0.0.0",
            () => {

                console.log(
                    `Employee API running on port ${PORT}`
                );

            }
        );

    })

    .catch(error => {

        console.error(
            "Application startup failed:",
            error
        );

        process.exit(1);

    });
