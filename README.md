# Car Rental Database (CarRentalDB)

**Authors:**  
Miraslau Alkhovik (248655) - database code </br>
Praskouya Horbach (248656) - documentation

## Project Overview

The goal of this project is to develop a comprehensive car rental management system. The system is designed to efficiently handle vehicles, employees, customers, reservations, payments, and activity logging. It aims to simplify and automate the car rental process by providing a well-structured database with clearly defined relationships between various entities.

## Main Project Assumptions

- **Table Relationships:**  
  All tables are interconnected via foreign keys to ensure data integrity and enable fast retrieval and modification of related records.

- **Security:**  
  The system incorporates user authorization with defined roles and privileges (Administrator, Manager, Employee) to control access to data and system functions.

- **Reservations and Payments:**  
  Customers can make vehicle reservations, process payments, and track the status of their reservations within the system.

- **Vehicle Management:**  
  Users can add new vehicles and manage their availability, types, and insurance information.

## Capabilities

- **Branch and Employee Management:**  
  Employees are assigned to various branches, and their details—including roles, positions, and salaries—are stored in the system.

- **Vehicle Search:**  
  The system enables easy searching for available vehicles based on criteria such as vehicle type, brand, model, and availability.

- **Activity Logging:**  
  All customer activities and payment transactions are logged, providing a complete history of system operations for auditing purposes.

- **Insurance and Service Monitoring:**  
  Users can monitor the status of vehicle insurance policies and technical inspections to ensure safety and compliance.

## Design Constraints

- **Performance:**  
  The system is designed for a small number of concurrent users and does not include advanced optimizations for handling large datasets.

- **External Integrations:**  
  There is no integration with external services (e.g., payment gateways), which may limit the system's flexibility in a broader context.

- **Mobile Compatibility:**  
  The project does not include a mobile version or a mobile-adapted interface, which restricts access on various platforms.

## Database Schema and Objects

### Key Tables and Entities

- **Branches:**  
  Stores information about rental branches, including branch ID, name, address, phone number, email, and timestamps for creation and updates.  
  *Relationships:* Linked to Employees (1-to-many) and Vehicles (1-to-many).

- **Roles:**  
  Contains user roles (e.g., Administrator, Manager, Employee) with a unique role ID, name, and description.  
  *Relationships:* Associated with Employees (1-to-many).

- **Employees:**  
  Stores employee data (ID, first name, last name, position, role, contact details, hire date, salary, and branch assignment).  
  *Relationships:* Linked to Roles and Branches.

- **VehicleType:**  
  Stores vehicle types (e.g., sedan, SUV, wagon) with unique names and optional descriptions.  
  *Relationships:* Linked to Vehicles.

- **Vehicles:**  
  Contains details about vehicles (registration number, brand, model, production year, type, branch, and availability).  
  *Relationships:* Linked to VehicleType, Branches, Insurance, Services, VehicleInspection, and Reservations.

- **Insurance:**  
  Stores vehicle insurance details such as provider, policy number, start and end dates, and premium.  
  *Relationships:* Linked to Vehicles.

- **Services:**  
  Contains information about vehicle service events (service date, description, cost).  
  *Relationships:* Linked to Vehicles.

- **VehicleInspection:**  
  Records vehicle inspection details (inspection date, inspector, result, and notes).  
  *Relationships:* Linked to Vehicles.

- **Customers:**  
  Stores customer information (first name, last name, contact details, address, and timestamps for creation and updates).  
  *Relationships:* Linked to Reservations and CustomerHistory.

- **Reservations:**  
  Manages vehicle reservations, including customer and vehicle associations, reservation date, rental period, total amount, and status.  
  *Relationships:* Linked to Customers, Vehicles, Payments, and CustomerHistory.

- **Payments:**  
  Records payment details for reservations (payment date, amount, and payment method).  
  *Relationships:* Linked to Reservations.

- **CustomerHistory:**  
  Stores a log of customer actions and transactions related to reservations.  
  *Relationships:* Linked to Customers and Reservations.

- **Users:**  
  Contains system user details (GUID, username, password hash and salt, and timestamps).  
  *Relationships:* Linked to Logs.

- **Logs:**  
  Records user activity logs for auditing purposes.  
  *Relationships:* Linked to Users.

## Roles and Privileges

- **Administrator:**  
  Has full control over the Branches table and overall system management.

- **Employee:**  
  Can manage reservations (SELECT, INSERT, UPDATE) and view vehicle data (SELECT).

- **Manager:**  
  Has full control over the Customers table, enabling comprehensive customer data management.

## Final Remarks

The Car Rental Database project offers a robust system for managing a car rental business. It establishes clear relationships between entities and implements essential security measures through role-based access control. While designed for a limited user base without external integrations or mobile support, the system provides a solid foundation for automating and streamlining car rental operations.
