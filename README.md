# Airport Management System

## Overview

The **Airport Management System** is a software solution designed to streamline and manage various airport operations, including flight scheduling, gate assignments, baggage handling, passenger check-ins, and boarding. The system aims to improve operational efficiency and ensure smooth and coordinated airport activities.

### Key Features:
- **Flight Operations**: Manage flight scheduling and gate assignments.
- **Passenger Management**: Handle ticket bookings, check-ins, and boarding processes.
- **Baggage Handling**: Track baggage linked to tickets and manage its handling.
- **Staff Management**: Administer airline and airport staff details and roles.
- **Operational Efficiency**: Optimize and automate various airport processes.

## Problem Statement

This system simulates and manages the operations of an airport. Key functions include:
- **Flight Scheduling**: Manage flight schedules and gate assignments.
- **Ticketing**: Handle passenger bookings with unique identifiers for each order and ticket.
- **Baggage Handling**: Track baggage for each passenger's ticket.
- **Passenger Check-In and Boarding**: Coordinate the check-in and boarding process for passengers.

The primary goal of this system is to improve operational efficiency and ensure smooth coordination across various airport functions.

## Business Rules
- The system manages operations for a **single airport** at a time.
- Passengers can book tickets **individually or as a group**, each booking identified by a unique **order_id**.
- Tickets are uniquely identified by **order_id** and **ticket_id**.
- Each ticket is associated with one or more pieces of **baggage**, each identified by a unique **baggage_id**.
- **Flights** are tracked by **flight_id**, and each flight has a **source** and **destination**.
- **Airlines** operate flights identified by **airline_id** and **route numbers**.
- The airport is managed by **airline staff**, identified by **staff_id**.
- **Cities** connected to the airport are tracked by **airport_code**.

## Entities

This system uses the following key entities to manage airport operations:

- **Airline**: Represents the airlines operating flights.
- **Terminal**: The physical areas for passenger processing.
- **Airport**: The overall airport entity being managed.
- **Passenger**: Individuals traveling through the airport.
- **Orders**: Represents the booking details for passengers.
- **Airline Staff**: Employees responsible for airline operations.
- **Flight**: Represents the scheduled flights.
- **Ticket**: Represents a passenger's travel ticket.
- **Baggage**: Represents luggage associated with a passenger.
- **Schedule**: Flight departure and arrival schedules.
- **Airport Staff**: Employees responsible for managing the airport.
- **Cleaning Schedule**: The maintenance schedule for airport facilities.
