# Employee Management System

## Project Overview

This project is an Employee Management System deployed on AWS using Terraform.

It uses a 3-tier architecture:

- Web Tier – HTML, CSS, JavaScript, Apache2
- Application Tier – Node.js and Express.js
- Database Tier – Amazon RDS MySQL

## AWS Services Used

- Amazon VPC
- Amazon EC2
- Application Load Balancer
- Auto Scaling Groups
- Amazon RDS MySQL
- NAT Gateway
- Internet Gateway
- Security Groups

## Architecture

Internet  
↓  
Public ALB  
↓  
Web ASG  
↓  
Internal ALB  
↓  
Application ASG  
↓  
RDS MySQL

## Terraform

Terraform is used to create and manage the complete AWS infrastructure.

### Terraform Commands

bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

### Application Features
Add Employee
View Employees
Delete Employee

Result:
The Employee Management System was successfully deployed using AWS and Terraform with 2 Auto Scaling Groups and 2 Application Load Balancers.
