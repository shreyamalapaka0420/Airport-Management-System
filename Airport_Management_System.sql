create database AirportManagementSystem_Group14

use AirportManagementSystem_Group14

/*-----table creation------*/

CREATE TABLE AIRLINE (
    airline_id INT PRIMARY KEY,
    route_number INT,
    airline_code VARCHAR(10),
    airline_name VARCHAR(20)
);

CREATE TABLE TERMINAL (
    terminal_id INT PRIMARY KEY,
    terminal_name VARCHAR(5)
);

CREATE TABLE AIRPORT (
    airport_id INT ,
    airport_name VARCHAR(255) PRIMARY KEY,
    city VARCHAR(20),
    state VARCHAR(20),
    country VARCHAR(20)
);

CREATE TABLE PASSENGER (
    passenger_id INT PRIMARY KEY,
    age INT,
    address VARCHAR(100),
    sex VARCHAR(10),
    govt_id_nos VARCHAR(10),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    dob DATETIME,
    contact_number INT,
    email VARCHAR(20)
);

ALTER TABLE PASSENGER
ALTER COLUMN contact_number VARCHAR(20);

ALTER TABLE PASSENGER
ALTER COLUMN email VARCHAR(255);


CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY,
    passenger_id INT,
    amount FLOAT,
    status VARCHAR(20),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id)
);

ALTER TABLE ORDERS
ADD CONSTRAINT fk_orders_passenger
FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id)
ON DELETE CASCADE;



CREATE TABLE AIRLINE_STAFF (
    staff_id INT PRIMARY KEY,
    airline_id INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    address VARCHAR(100),
    ssn VARCHAR(12),
    email_id VARCHAR(20),
    contact_number INT,
    job_group VARCHAR(10),
    gender VARCHAR(10),
    FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
);

ALTER TABLE AIRLINE_STAFF
ALTER COLUMN contact_number BIGINT;

CREATE TABLE FLIGHT (
    flight_id INT PRIMARY KEY,
    duration INT,
    flight_type VARCHAR(255),
    departure_time DATETIME,
    arrival_time DATETIME,
    destination VARCHAR(255),
    source VARCHAR(255),
    status VARCHAR(10),
    no_pax INT,
    airline_id INT,
	
    FOREIGN KEY (destination) REFERENCES AIRPORT(airport_name),
    FOREIGN KEY (source) REFERENCES AIRPORT(airport_name),
    FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
);



ALTER TABLE FLIGHT
ADD seats_filled INT DEFAULT 0 NOT NULL;

CREATE TABLE TICKET (
    ticket_id INT PRIMARY KEY,
    order_id INT,
    flight_id INT,
    seat_no VARCHAR(255),
    meal_preferences VARCHAR(20),
    source VARCHAR(255),
    destination VARCHAR(255),
    date_of_travel DATETIME,
    class VARCHAR(255),
    payment_type VARCHAR(20),
    Member_id INT,
    Transaction_amount FLOAT,
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id),
    FOREIGN KEY (source) REFERENCES AIRPORT(airport_name),
    FOREIGN KEY (destination) REFERENCES AIRPORT(airport_name)
);

CREATE TABLE BAGGAGE (
    baggage_id INT PRIMARY KEY,
    ticket_id INT,
    weight FLOAT CHECK (weight >= 0 AND weight <= 100),
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
);

ALTER TABLE BAGGAGE
ADD weight FLOAT;


CREATE TABLE SCHEDULE (
    schedule_id INT PRIMARY KEY,
    flight_id INT,
    terminal_id INT,
    Arrival_time DATETIME,
    Departure_time DATETIME,
    FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id),
    FOREIGN KEY (terminal_id) REFERENCES TERMINAL(terminal_id)
);

CREATE TABLE AIRPORT (
    airport_id INT ,
    airport_name VARCHAR(255) PRIMARY KEY,
    city VARCHAR(20),
    state VARCHAR(20),
    country VARCHAR(20)
);

CREATE TABLE AIRPORT_STAFF (
  airportStaff_id INT PRIMARY KEY,
  airport_name VARCHAR(255),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  gender VARCHAR(10),
  job_group VARCHAR(50),
  ssn VARCHAR(11) ,
  contact_number VARCHAR(15) ,
  email VARCHAR(100) ,
  address VARCHAR(255),
  FOREIGN KEY (airport_name) REFERENCES AIRPORT(airport_name),
);

CREATE TABLE CLEANING_SCHEDULE (
    schedule_id INT PRIMARY KEY,
    airport_name VARCHAR(255),
    airportStaff_id INT,
    area_to_clean VARCHAR(255),
    cleaning_date DATE,
    cleaning_time TIME,
    special_requirements TEXT,
    FOREIGN KEY (airport_name) REFERENCES AIRPORT(airport_name),
    FOREIGN KEY (airportStaff_id) REFERENCES AIRPORT_STAFF(airportStaff_id)
);


ALTER TABLE AIRLINE_STAFF
ADD CONSTRAINT fk_airlinestaff_airline
FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
ON DELETE CASCADE;


ALTER TABLE FLIGHT
ADD CONSTRAINT fk_flight_airline
FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_flight_destination
FOREIGN KEY (destination) REFERENCES AIRPORT(airport_name)
ON DELETE CASCADE,
ADD CONSTRAINT fk_flight_source
FOREIGN KEY (source) REFERENCES AIRPORT(airport_name)
ON DELETE CASCADE;


ALTER TABLE TICKET
ADD CONSTRAINT fk_ticket_orders
FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_ticket_flight
FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_ticket_source
FOREIGN KEY (source) REFERENCES AIRPORT(airport_name)
ON DELETE CASCADE,
ADD CONSTRAINT fk_ticket_destination
FOREIGN KEY (destination) REFERENCES AIRPORT(airport_name)
ON DELETE CASCADE;


ALTER TABLE BAGGAGE
ADD CONSTRAINT fk_baggage_ticket
FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
ON DELETE CASCADE;


ALTER TABLE SCHEDULE
ADD CONSTRAINT fk_schedule_flight
FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_schedule_terminal
FOREIGN KEY (terminal_id) REFERENCES TERMINAL(terminal_id)
ON DELETE CASCADE;


ALTER TABLE CLEANING_SCHEDULE
ADD CONSTRAINT fk_cleaning_schedule_airportstaff
FOREIGN KEY (airportStaff_id) REFERENCES AIRPORT_STAFF(airportStaff_id)
ON DELETE CASCADE;


 
go

/*-----function to calculate age ---------*/

ALTER TABLE PASSENGER
ADD age AS DATEDIFF(YEAR, dob, GETDATE()) - 
    CASE
        WHEN (MONTH(dob) > MONTH(GETDATE())) OR 
             (MONTH(dob) = MONTH(GETDATE()) AND DAY(dob) > DAY(GETDATE())) 
        THEN 1 
        ELSE 0 
    END;

go

/*---------table level check constraint--------*/

CREATE FUNCTION dbo.CheckDepartureBeforeArrival
(
    @departure_time DATETIME,
    @arrival_time DATETIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT

    IF @departure_time < @arrival_time
        SET @Result = 1 -- Valid case
    ELSE
        SET @Result = 0 -- Invalid case

    RETURN @Result
END

go

ALTER TABLE FLIGHT
ADD CONSTRAINT chk_FlightTimeValidity CHECK (dbo.CheckDepartureBeforeArrival(departure_time, arrival_time) = 1);

go

/*--- stored procedures to enter values to table ----------*/

CREATE PROCEDURE sp_InsertAirline
@airline_id INT,
@route_number INT,
@airline_code VARCHAR(10),
@airline_name VARCHAR(20)
AS
BEGIN
    INSERT INTO AIRLINE (airline_id, route_number, airline_code, airline_name)
    VALUES (@airline_id, @route_number, @airline_code, @airline_name)
END

go

CREATE PROCEDURE sp_InsertTerminal
@terminal_id INT,
@terminal_name VARCHAR(5)
AS
BEGIN
    INSERT INTO TERMINAL (terminal_id, terminal_name)
    VALUES (@terminal_id, @terminal_name)
END

go

CREATE PROCEDURE sp_InsertAirport
@airport_id INT,
@airport_name VARCHAR(255),
@city VARCHAR(20),
@state VARCHAR(20),
@country VARCHAR(20)
AS
BEGIN
    INSERT INTO AIRPORT (airport_id, airport_name, city, state, country)
    VALUES (@airport_id, @airport_name, @city, @state, @country)
END

go


CREATE PROCEDURE sp_InsertFlight
@flight_id INT,
@duration INT,
@flight_type VARCHAR(255),
@departure_time DATETIME,
@arrival_time DATETIME,
@destination VARCHAR(255),
@source VARCHAR(255),
@status VARCHAR(10),
@no_pax INT,
@airline_id INT
AS
BEGIN
    INSERT INTO FLIGHT (flight_id, duration, flight_type, departure_time, arrival_time, destination, source, status, no_pax, airline_id)
    VALUES (@flight_id, @duration, @flight_type, @departure_time, @arrival_time, @destination, @source, @status, @no_pax, @airline_id)
END

go

CREATE PROCEDURE sp_InsertAirlineStaff
@staff_id INT,
@airline_id INT,
@first_name VARCHAR(20),
@last_name VARCHAR(20),
@address VARCHAR(100),
@ssn VARCHAR(12),
@email_id VARCHAR(20),
@contact_number BIGINT,
@job_group VARCHAR(10),
@gender VARCHAR(10)
AS
BEGIN
    INSERT INTO AIRLINE_STAFF (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender)
    VALUES (@staff_id, @airline_id, @first_name, @last_name, @address, @ssn, @email_id, @contact_number, @job_group, @gender)
END

go

CREATE PROCEDURE sp_insert_baggage
    @baggage_id INT,
    @ticket_id INT
AS
BEGIN
    DECLARE @v_weight FLOAT;
    DECLARE @v_ticket_class VARCHAR(20);

    SELECT @v_ticket_class = class FROM ticket WHERE ticket_id = @ticket_id;
    
    IF @v_ticket_class = 'Business' 
        SET @v_weight = 200.00;
    IF @v_ticket_class = 'Business Pro' 
        SET @v_weight = 300.00;
    IF @v_ticket_class = 'First Class' 
        SET @v_weight = 400.00;
    IF @v_ticket_class = 'Economy' 
        SET @v_weight = 100.00;
    
    INSERT INTO baggage (baggage_id, ticket_id, weight)
    VALUES (@baggage_id, @ticket_id, @v_weight);
    
    PRINT 'Baggage ' + CAST(@baggage_id AS VARCHAR) + ' weight updated to ' + CAST(@v_weight AS VARCHAR);
END

GO

CREATE PROCEDURE sp_InsertSchedule
@schedule_id INT,
@flight_id INT,
@terminal_id INT,
@Arrival_time DATETIME,
@Departure_time DATETIME
AS
BEGIN
    INSERT INTO SCHEDULE (schedule_id, flight_id, terminal_id, Arrival_time, Departure_time)
    VALUES (@schedule_id, @flight_id, @terminal_id, @Arrival_time, @Departure_time)
END

go

drop sequence dbo.ORDERS_SEQ
drop sequence dbo.PASSENGER_SEQ
drop procedure INSERT_PASSENGER

CREATE SEQUENCE dbo.ORDERS_SEQ
    AS INT
    START WITH 1
    INCREMENT BY 1;

CREATE SEQUENCE dbo.PASSENGER_SEQ
    AS INT
    START WITH 1
    INCREMENT BY 1;

go


CREATE PROCEDURE INSERT_PASSENGER
    @P_ADDRESS VARCHAR(255),
    @P_SEX VARCHAR(255),
    @P_GOVT_ID_NOS VARCHAR(255),
    @P_FIRST_NAME VARCHAR(255),
    @P_LAST_NAME VARCHAR(255),
    @P_DOB DATETIME,
    @P_CONTACT_NUMBER VARCHAR(255),
    @P_EMAIL VARCHAR(255),
    @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @V_PASSENGER_ID INT;

    -- [Validation logic as before]

    BEGIN TRY
        -- Check if email is already present in the passenger table
        SELECT @V_PASSENGER_ID = PASSENGER_ID 
        FROM PASSENGER 
        WHERE EMAIL = @P_EMAIL;

        IF @V_PASSENGER_ID IS NULL
        BEGIN
            -- Get the next passenger ID from the sequence
            SET @V_PASSENGER_ID = NEXT VALUE FOR dbo.PASSENGER_SEQ;

            -- Insert a new passenger with the new passenger ID
            INSERT INTO PASSENGER (passenger_id, ADDRESS, SEX, GOVT_ID_NOS, FIRST_NAME, LAST_NAME, DOB, CONTACT_NUMBER, EMAIL)
            VALUES (@V_PASSENGER_ID, @P_ADDRESS, @P_SEX, @P_GOVT_ID_NOS, @P_FIRST_NAME, @P_LAST_NAME, @P_DOB, @P_CONTACT_NUMBER, @P_EMAIL);

            PRINT 'New passenger created with ID: ' + CAST(@V_PASSENGER_ID AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'Existing passenger found with ID: ' + CAST(@V_PASSENGER_ID AS VARCHAR);
        END

        -- Create a new order
        SET @NewOrderID = NEXT VALUE FOR dbo.ORDERS_SEQ;
        INSERT INTO ORDERS (ORDER_ID, PASSENGER_ID, AMOUNT, STATUS)
        VALUES (@NewOrderID, @V_PASSENGER_ID, 0, 'Pending')
        PRINT 'Order created successfully with ID: ' + CAST(@NewOrderID AS VARCHAR);

    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting data: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO

CREATE FUNCTION check_airport
    (@in_airport_name VARCHAR(255))
RETURNS INT
AS
BEGIN
    DECLARE @v_result INT;
    SELECT @v_result = COUNT(*) FROM airport WHERE airport_name = @in_airport_name;
    RETURN @v_result;
END
GO

CREATE FUNCTION check_flight
    (@in_flight_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @v_result INT;
    SELECT @v_result = COUNT(*) FROM flight WHERE flight_id = @in_flight_id;
    RETURN @v_result;
END

GO


drop SEQUENCE dbo.ticket_seq
drop SEQUENCE dbo.baggage_id_seq
drop PROCEDURE INSERT_TICKET

CREATE SEQUENCE dbo.ticket_seq
    AS INT
    START WITH 1
    INCREMENT BY 1;
go

CREATE SEQUENCE dbo.baggage_id_seq
    AS INT
    START WITH 1
    INCREMENT BY 1;

go

CREATE PROCEDURE INSERT_TICKET
    @in_order_id INT,
    @in_flight_id INT,
    @in_seat_no VARCHAR(255),
    @in_meal_preferences VARCHAR(255),
    @in_source VARCHAR(255),
    @in_destination VARCHAR(255),
    @in_date_of_travel DATETIME,
    @in_class VARCHAR(255),
    @in_payment_type VARCHAR(255),
    @in_member_id INT,
    @in_transaction_amount FLOAT
AS
BEGIN
    BEGIN TRY
        DECLARE @l_d_airport_count INT;
        DECLARE @l_s_airport_count INT;
        DECLARE @l_flight_count INT;
        DECLARE @l_ticket_id INT;
        DECLARE @l_baggage_id INT; -- Declare variable for baggage ID

        -- Retrieve next value for ticket_id from sequence
        SELECT @l_ticket_id = NEXT VALUE FOR dbo.ticket_seq;

        -- Check if flight exists
        SELECT @l_flight_count = dbo.check_flight(@in_flight_id);
        IF @l_flight_count = 0
        BEGIN
            RAISERROR('Flight_id does not exist in flight table', 16, 1);
            RETURN;
        END

        -- Check if destination airport exists
        SELECT @l_d_airport_count = dbo.check_airport(@in_destination);
        IF @l_d_airport_count = 0
        BEGIN
            RAISERROR('Destination airport does not exist in airport table', 16, 1);
            RETURN;
        END

        -- Check if source airport exists
        SELECT @l_s_airport_count = dbo.check_airport(@in_source);
        IF @l_s_airport_count = 0
        BEGIN
            RAISERROR('Source airport does not exist in airport table', 16, 1);
            RETURN;
        END

        -- Insert ticket record
        INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id,Transaction_amount)
        VALUES (@l_ticket_id, @in_order_id, @in_flight_id, @in_seat_no, @in_meal_preferences, @in_source, @in_destination, @in_date_of_travel, @in_class, @in_payment_type, @in_member_id,@in_transaction_amount)

        -- Update order amount
        UPDATE ORDERS SET amount = @in_transaction_amount WHERE order_id = @in_order_id;
		UPDATE ORDERS SET status='Success'  WHERE order_id = @in_order_id;

        -- Update flight seats filled
       -- Update flight seats filled
	
		BEGIN TRY
		PRINT 'Before update SEATS_FILLED for flight_id ' + CAST(@in_flight_id AS VARCHAR);
		SELECT seats_filled FROM FLIGHT WHERE flight_id = @in_flight_id;
		UPDATE FLIGHT SET seats_filled = seats_filled + 1 WHERE flight_id = @in_flight_id;

		PRINT 'After update seats_filled for flight_id ' + CAST(@in_flight_id AS VARCHAR);
		SELECT seats_filled FROM FLIGHT WHERE flight_id = @in_flight_id;
		END TRY
		BEGIN CATCH
			PRINT 'Error occurred during FLIGHT update: ' + ERROR_MESSAGE();
		END CATCH

        -- Retrieve next value for baggage_id from sequence
        SELECT @l_baggage_id = NEXT VALUE FOR dbo.baggage_id_seq;

        -- Insert baggage record using the new baggage_id
        EXEC dbo.sp_insert_baggage @l_baggage_id, @l_ticket_id;

    END TRY
    BEGIN CATCH
        PRINT 'Error occurred in procedure: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH
END
GO

CREATE PROCEDURE SP_AssignCleaningTasks
    @airportStaff_id INT,
    @airport_name VARCHAR(255),
    @area_to_clean VARCHAR(255),
    @cleaning_date DATE,
    @cleaning_time TIME,
    @special_requirements TEXT
AS
BEGIN
    DECLARE @newScheduleID INT;
    SET @newScheduleID = NEXT VALUE FOR Seq_ScheduleID;

CREATE PROCEDURE SP_UpdateCleaningTask
    @schedule_id INT,
    @airportStaff_id INT,
    @area_to_clean VARCHAR(255),
    @cleaning_date DATE,
    @cleaning_time TIME,
    @special_requirements TEXT
AS
BEGIN
    UPDATE CLEANING_SCHEDULE
    SET airportStaff_id = @airportStaff_id,
        area_to_clean = @area_to_clean,
        cleaning_date = @cleaning_date,
        cleaning_time = @cleaning_time,
        special_requirements = @special_requirements
    WHERE schedule_id = @schedule_id;
END;


/*----------insertion of values------------------------------*/

EXEC sp_InsertAirline 1, 101, 'A101', 'AirOne'
EXEC sp_InsertAirline 2, 102, 'A102', 'AirTwo'
EXEC sp_InsertAirline 3, 103, 'A103', 'AirThree'
EXEC sp_InsertAirline 4, 104, 'A104', 'AirFour'
EXEC sp_InsertAirline 5, 105, 'A105', 'AirFive'
EXEC sp_InsertAirline 6, 106, 'A106', 'AirSix'
EXEC sp_InsertAirline 7, 107, 'A107', 'AirSeven'
EXEC sp_InsertAirline 8, 108, 'A108', 'AirEight'
EXEC sp_InsertAirline 9, 109, 'A109', 'AirNine'
EXEC sp_InsertAirline 10, 110, 'A110', 'AirTen'

EXEC sp_InsertTerminal 1, 'T1'
EXEC sp_InsertTerminal 2, 'T2'
EXEC sp_InsertTerminal 3, 'T3'
EXEC sp_InsertTerminal 4, 'T4'
EXEC sp_InsertTerminal 5, 'T5'
EXEC sp_InsertTerminal 6, 'T6'
EXEC sp_InsertTerminal 7, 'T7'
EXEC sp_InsertTerminal 8, 'T8'
EXEC sp_InsertTerminal 9, 'T9'
EXEC sp_InsertTerminal 10, 'T10'

EXEC sp_InsertAirport 1, 'JFK', 'New York', 'NY', 'USA'
EXEC sp_InsertAirport 2, 'LAX', 'Los Angeles', 'CA', 'USA'
EXEC sp_InsertAirport 3, 'ORD', 'Chicago', 'IL', 'USA'
EXEC sp_InsertAirport 4, 'ATL', 'Atlanta', 'GA', 'USA'
EXEC sp_InsertAirport 5, 'DFW', 'Dallas', 'TX', 'USA'
EXEC sp_InsertAirport 6, 'DEN', 'Denver', 'CO', 'USA'
EXEC sp_InsertAirport 7, 'SFO', 'San Francisco', 'CA', 'USA'
EXEC sp_InsertAirport 8, 'LAS', 'Las Vegas', 'NV', 'USA'
EXEC sp_InsertAirport 9, 'MIA', 'Miami', 'FL', 'USA'
EXEC sp_InsertAirport 10, 'SEA', 'Seattle', 'WA', 'USA'



EXEC sp_InsertAirlineStaff 1, 1, 'John', 'Doe', '123 Main St', 'SSN001', 'john.doe@email.com', 1234567890, 'Pilot', 'Male'
EXEC sp_InsertAirlineStaff 2, 2, 'Jane', 'Smith', '234 Second St', 'SSN002', 'jane.smith@email.com', 2345678901, 'Crew', 'Female'
EXEC sp_InsertAirlineStaff 3, 3, 'Mike', 'Johnson', '345 Third Ave', 'SSN003', 'mike.johnson@email.com', 3456789012, 'Engineer', 'Male'
EXEC sp_InsertAirlineStaff 4, 4, 'Emily', 'Clark', '456 Fourth Rd', 'SSN004', 'emily.clark@email.com', 4567890123, 'Pilot', 'Female'
EXEC sp_InsertAirlineStaff 5, 5, 'Alex', 'Wright', '567 Fifth Ln', 'SSN005', 'alex.wright@email.com', 5678901234, 'Crew', 'Male'
EXEC sp_InsertAirlineStaff 6, 6, 'Anna', 'Lee', '678 Sixth Dr', 'SSN006', 'anna.lee@email.com', 6789012345, 'Admin', 'Female'
EXEC sp_InsertAirlineStaff 7, 7, 'Brian', 'King', '789 Seventh Pl', 'SSN007', 'brian.king@email.com', 7890123456, 'Engineer', 'Male'
EXEC sp_InsertAirlineStaff 8, 8, 'Lisa', 'Green', '890 Eighth St', 'SSN008', 'lisa.green@email.com', 8901234567, 'Pilot', 'Female'
EXEC sp_InsertAirlineStaff 9, 9, 'David', 'White', '901 Ninth Ave', 'SSN009', 'david.white@email.com', 9012345678, 'Crew', 'Male'
EXEC sp_InsertAirlineStaff 10, 10, 'Sarah', 'Brown', '1010 Tenth Rd', 'SSN010', 'sarah.brown@email.com', 1012345678, 'Admin', 'Female'

select * from AIRLINE_STAFF

EXEC sp_InsertFlight 1, 120, 'Commercial', '2023-12-01 08:00', '2023-12-01 10:00', 'JFK', 'LAX', 'On Time', 150, 1
EXEC sp_InsertFlight 2, 180, 'Commercial', '2023-12-01 09:00', '2023-12-01 12:00', 'LAX', 'ORD', 'Delayed', 200, 2
EXEC sp_InsertFlight 3, 90, 'Private', '2023-12-01 07:30', '2023-12-01 09:00', 'ORD', 'ATL', 'On Time', 50, 3
EXEC sp_InsertFlight 4, 210, 'International', '2023-12-01 15:00', '2023-12-01 18:30', 'ATL', 'DFW', 'Cancelled', 250, 4
EXEC sp_InsertFlight 5, 150, 'Commercial', '2023-12-02 10:00', '2023-12-02 12:30', 'DFW', 'DEN', 'On Time', 180, 5
EXEC sp_InsertFlight 6, 60, 'Private', '2023-12-02 06:00', '2023-12-02 07:00', 'DEN', 'SFO', 'Delayed', 40, 6
EXEC sp_InsertFlight 7, 140, 'International', '2023-12-02 20:00', '2023-12-02 22:20', 'SFO', 'LAS', 'On Time', 220, 7
EXEC sp_InsertFlight 8, 200, 'Commercial', '2023-12-03 09:00', '2023-12-03 12:20', 'LAS', 'MIA', 'Cancelled', 210, 8
EXEC sp_InsertFlight 9, 170, 'Private', '2023-12-03 08:00', '2023-12-03 10:50', 'MIA', 'SEA', 'Delayed', 60, 9
EXEC sp_InsertFlight 10, 130, 'Commercial', '2023-12-03 16:00', '2023-12-03 18:10', 'SEA', 'JFK', 'On Time', 160, 10

select * from FLIGHT

EXEC sp_InsertFlight 11, 100, 'Commercial', '2023-12-04 12:00', '2023-12-04 11:00', 'JFK', 'LAX', 'Delayed', 180, 1


EXEC sp_InsertSchedule 1, 1, 1, '2023-12-01 10:00', '2023-12-01 08:00';
EXEC sp_InsertSchedule 2, 2, 2, '2023-12-01 12:00', '2023-12-01 09:00';
EXEC sp_InsertSchedule 3, 3, 3, '2023-12-01 09:00', '2023-12-01 07:30';
EXEC sp_InsertSchedule 4, 4, 4, '2023-12-01 18:30', '2023-12-01 15:00';
EXEC sp_InsertSchedule 5, 5, 5, '2023-12-02 12:30', '2023-12-02 10:00';
EXEC sp_InsertSchedule 6, 6, 6, '2023-12-02 07:00', '2023-12-02 06:00';
EXEC sp_InsertSchedule 7, 7, 7, '2023-12-02 22:20', '2023-12-02 20:00';
EXEC sp_InsertSchedule 8, 8, 8, '2023-12-03 12:20', '2023-12-03 09:00';
EXEC sp_InsertSchedule 9, 9, 9, '2023-12-03 10:50', '2023-12-03 08:00';
EXEC sp_InsertSchedule 10, 10, 10, '2023-12-03 18:10', '2023-12-03 16:00';


DECLARE @NewOrderID1 INT;
EXEC INSERT_PASSENGER '123 Main St', 'Male', 'A123456789', 'John', 'Doe', '1997-01-01', '1234567890', 'johndoe@example.com', @NewOrderID1 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID1 AS VARCHAR);

DECLARE @NewOrderID2 INT;
EXEC INSERT_PASSENGER '456 Elm St', 'Female', 'B234567890', 'Jane', 'Smith', '1996-02-02', '2345678901', 'janesmith@example.com', @NewOrderID2 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID2 AS VARCHAR);

DECLARE @NewOrderID3 INT;
EXEC INSERT_PASSENGER '789 Oak Rd', 'Other', 'C345678901', 'Alex', 'Taylor', '1995-03-03', '3456789012', 'alextaylor@example.com', @NewOrderID3 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID3 AS VARCHAR);

DECLARE @NewOrderID4 INT;
EXEC INSERT_PASSENGER '101 Pine Ave', 'Male', 'D456789012', 'Michael', 'Brown', '1994-04-04', '4567890123', 'michaelbrown@example.com', @NewOrderID4 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID4 AS VARCHAR);

DECLARE @NewOrderID5 INT;
EXEC INSERT_PASSENGER '202 Birch Ln', 'Female', 'E567890123', 'Emily', 'White', '1993-05-05', '5678901234', 'emilywhite@example.com', @NewOrderID5 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID5 AS VARCHAR);

DECLARE @NewOrderID6 INT;
EXEC INSERT_PASSENGER '303 Cedar Dr', 'Male', 'F678901234', 'Chris', 'Johnson', '1992-06-06', '6789012345', 'chrisjohnson@example.com', @NewOrderID6 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID6 AS VARCHAR);

DECLARE @NewOrderID7 INT;
EXEC INSERT_PASSENGER '404 Spruce Pl', 'Female', 'G789012345', 'Sarah', 'Miller', '1991-07-07', '7890123456', 'sarahmiller@example.com', @NewOrderID7 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID7 AS VARCHAR);

DECLARE @NewOrderID8 INT;
EXEC INSERT_PASSENGER '505 Maple St', 'Other', 'H890123456', 'Jordan', 'Wilson', '1990-08-08', '8901234567', 'jordanwilson@example.com', @NewOrderID8 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID8 AS VARCHAR);

DECLARE @NewOrderID9 INT;
EXEC INSERT_PASSENGER '606 Willow Way', 'Male', 'I901234567', 'Gary', 'Anderson', '1989-09-09', '9012345678', 'garyanderson@example.com', @NewOrderID9 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID9 AS VARCHAR);

DECLARE @NewOrderID10 INT;
EXEC INSERT_PASSENGER '707 Aspen Blvd', 'Female', 'J012345678', 'Laura', 'Jackson', '1988-10-10', '0123456789', 'laurajackson@example.com', @NewOrderID10 OUTPUT;
PRINT 'New order created with ID: ' + CAST(@NewOrderID10 AS VARCHAR);

select * from ORDERS


EXEC INSERT_TICKET 1, 1, '1A', 'Vegetarian', 'JFK', 'LAX', '2023-12-01', 'Economy', 'Credit Card', 1, 500;
EXEC INSERT_TICKET 2, 2, '2B', 'Vegan', 'LAX', 'ORD', '2023-12-01', 'Business', 'Debit Card', 2, 750;
EXEC INSERT_TICKET 3, 3, '3C', 'Gluten-Free', 'ORD', 'ATL', '2023-12-01', 'First Class', 'Credit Card', 3, 300;
EXEC INSERT_TICKET 4, 4, '4D', 'No Preferences', 'ATL', 'DFW', '2023-12-01', 'Economy', 'PayPal', 4, 450;
EXEC INSERT_TICKET 5, 5, '5E', 'Halal', 'DFW', 'DEN', '2023-12-02', 'Business Pro', 'Credit Card', 5, 600;
EXEC INSERT_TICKET 6, 6, '6F', 'Kosher', 'DEN', 'SFO', '2023-12-02', 'Economy', 'Cash', 6, 350;
EXEC INSERT_TICKET 7, 7, '7G', 'No Preferences', 'SFO', 'LAS', '2023-12-02', 'First Class', 'Debit Card', 7, 550;
EXEC INSERT_TICKET 8, 8, '8H', 'Vegetarian', 'LAS', 'MIA', '2023-12-03', 'Business', 'Credit Card', 8, 700;
EXEC INSERT_TICKET 9, 9, '9I', 'Vegan', 'MIA', 'SEA', '2023-12-03', 'Economy', 'PayPal', 9, 400;
EXEC INSERT_TICKET 10, 10, '10J', 'Gluten-Free', 'SEA', 'JFK', '2023-12-03', 'Business Pro', 'Debit Card', 10, 500;

select * from Ticket

select * from Baggage

select * from orders

select * from Flight

/* to check the procedures---*/
delete baggage
delete ticket
delete orders 
delete passenger

delete AIRLINE
delete TERMINAL
delete AIRLINE_STAFF
delete flight
delete SCHEDULE

EXEC SP_AssignCleaningTasks @airportStaff_id = 1, @airport_name = 'ATL', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 2, @airport_name = 'DEN', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 3, @airport_name = 'DFW', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 4, @airport_name = 'JFK', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 5, @airport_name = 'LAS', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 6, @airport_name = 'MIA', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 7, @airport_name = 'ORD', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 8, @airport_name = 'SEA', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 9, @airport_name = 'SFO', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';
EXEC SP_AssignCleaningTasks @airportStaff_id = 10, @airport_name = 'LAX', @area_to_clean = 'Terminal 1', @cleaning_date = '2023-12-25', @cleaning_time = '08:00:00', @special_requirements = 'Deep clean required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 1,
    @airportStaff_id = 1,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 2,
    @airportStaff_id = 2,
    @area_to_clean = 'Loue Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 3,
    @airportStaff_id = 3,
    @area_to_clean = 'Louase Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 4,
    @airportStaff_id = 4,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 5,
    @airportStaff_id = 5,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 6,
    @airportStaff_id = 6,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 7,
    @airportStaff_id = 7,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 8,
    @airportStaff_id = 8,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 9,
    @airportStaff_id = 9,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

EXEC SP_UpdateCleaningTask
    @schedule_id = 10,
    @airportStaff_id = 10,
    @area_to_clean = 'Lounge Area',
    @cleaning_date = '2023-12-02',
    @cleaning_time = '09:00:00',
    @special_requirements = 'Deep Clean Required';

	Select * from Cleaning_Schedule;

--View for Monthly Ticket Sales
CREATE VIEW monthly_ticket_sales AS
SELECT FORMAT(date_of_travel, 'yyyy-MM') AS month,
       SUM(Transaction_amount) AS total_sales
FROM ticket
GROUP BY FORMAT(date_of_travel, 'yyyy-MM');
GO

SELECT * FROM monthly_ticket_sales;

-----------Views
--View for number of airport in each each country
CREATE VIEW count_of_airport_in_each_country AS
SELECT COUNT(*) AS airport_count, country 
FROM AIRPORT
GROUP BY country;
GO

SELECT * FROM count_of_airport_in_each_country;

--view for number of staff per airline
CREATE VIEW airline_staff_counts AS
    SELECT AIRLINE.airline_name, COUNT(*) AS num_staff
    FROM AIRLINE_STAFF
    JOIN AIRLINE ON AIRLINE_STAFF.airline_id = AIRLINE.airline_id
    GROUP BY AIRLINE.airline_name;
GO

SELECT * FROM airline_staff_counts;


--View for calculating flight revenue per airline
CREATE VIEW flight_revenue AS
SELECT SUM(o.amount) AS Revenue, al.airline_name
FROM ORDERS o
JOIN TICKET t ON t.order_id = o.order_id
JOIN FLIGHT f ON f.flight_id = t.flight_id
JOIN AIRLINE al ON al.airline_id = f.airline_id
GROUP BY al.airline_name;
GO

SELECT * FROM flight_revenue;

/*------------------------------------------*/


/* ...previous code... */

/* ALTER TABLE ORDERS to include ON CASCADE DELETE for passenger_id */


/* ...other tables creation... */

