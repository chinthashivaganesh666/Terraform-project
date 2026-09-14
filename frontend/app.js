const form =
    document.getElementById("employeeForm");

const employeeList =
    document.getElementById("employeeList");

const message =
    document.getElementById("message");


async function loadEmployees() {

    try {

        const response =
            await fetch("/api/employees");

        if (!response.ok) {

            throw new Error(
                "Unable to load employees"
            );

        }

        const employees =
            await response.json();

        employeeList.innerHTML = "";


        if (employees.length === 0) {

            employeeList.innerHTML =
                "<p>No employees found.</p>";

            return;
        }


        employees.forEach(employee => {

            const div =
                document.createElement("div");

            div.className =
                "employee";


            div.innerHTML = `

                <div class="employee-info">

                    <strong>
                        ${escapeHtml(employee.name)}
                    </strong>

                    <span>
                        ${escapeHtml(employee.email)}
                    </span>

                    <span>
                        ${escapeHtml(employee.department)}
                    </span>

                </div>

                <button
                    class="delete"
                    onclick="deleteEmployee(${employee.id})"
                >
                    Delete
                </button>

            `;


            employeeList.appendChild(div);

        });

    }
    catch (error) {

        message.textContent =
            error.message;

    }
}


form.addEventListener(
    "submit",
    async function(event) {

        event.preventDefault();


        const name =
            document
                .getElementById("name")
                .value
                .trim();

        const email =
            document
                .getElementById("email")
                .value
                .trim();

        const department =
            document
                .getElementById("department")
                .value
                .trim();


        try {

            const response =
                await fetch(
                    "/api/employees",
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/json"
                        },

                        body:
                            JSON.stringify({
                                name,
                                email,
                                department
                            })
                    }
                );


            const data =
                await response.json();


            if (!response.ok) {

                throw new Error(
                    data.error ||
                    "Unable to add employee"
                );

            }


            form.reset();

            message.textContent =
                "Employee added successfully.";

            await loadEmployees();

        }
        catch (error) {

            message.textContent =
                error.message;

        }
    }
);


async function deleteEmployee(id) {

    try {

        const response =
            await fetch(
                `/api/employees/${id}`,
                {
                    method: "DELETE"
                }
            );


        if (!response.ok) {

            throw new Error(
                "Unable to delete employee"
            );

        }


        message.textContent =
            "Employee deleted successfully.";

        await loadEmployees();

    }
    catch (error) {

        message.textContent =
            error.message;

    }
}


function escapeHtml(value) {

    const div =
        document.createElement("div");

    div.textContent = value;

    return div.innerHTML;
}


loadEmployees();
