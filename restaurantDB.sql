CREATE TYPE order_status_type AS ENUM ('IN_PROGRESS','SERVED','CANCELLED');
CREATE TYPE reservation_status_type AS ENUM ('PENDING','CONFIRMED','CANCELLED','SEATED');
CREATE TYPE audit_op_type AS ENUM ('INSERT','UPDATE','DELETE');
CREATE TYPE role_type AS ENUM ('Server','Host','Cook');
CREATE TYPE category_type AS ENUM ('Appetizer','Entree','Salad','Dessert','Drink');

CREATE TABLE AuditLog (
	log_id INT generated always as identity PRIMARY KEY,
	name_table VARCHAR(100) NOT NULL,
	operation audit_op_type  NOT NULL,
	row_id VARCHAR(100) NOT NULL,
	changed_by VARCHAR(100),
	change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customers(
	customer_id INT generated always as identity PRIMARY KEY,
	customer_name VARCHAR(255) NOT NULL,
	phone VARCHAR(100)
);

CREATE TABLE Employees(
	employee_id INT generated always as identity PRIMARY KEY,
	emp_name VARCHAR(255) NOT NULL,
	emp_role role_type
);


CREATE TABLE MenuItems(
	item_id INT generated always as identity PRIMARY KEY,
	item_name VARCHAR(100) NOT NULL,
	category category_type,
	price INT
);

CREATE TABLE Orders(
	order_id INT generated always as identity PRIMARY KEY,
	customer_id INT,
	employee_id INT,
	order_date  timestamp DEFAULT CURRENT_TIMESTAMP,
	status order_status_type DEFAULT 'IN_PROGRESS',
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL,
  	FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE SET NULL
);

CREATE TABLE OrderItems(
	order_id INT NOT NULL,
	item_id INT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	unit_price INT NOT NULL,
	FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE SET NULL,
	FOREIGN KEY (item_id) REFERENCES MenuItems(item_id) ON DELETE SET NULL
);

CREATE TABLE Reservations(
	reservation_id INT generated always as identity PRIMARY KEY,
	customer_id INT NOT NULL,
	reservation_time timestamp DEFAULT CURRENT_TIMESTAMP,
	num_people INT DEFAULT 1,
	status reservation_status_type DEFAULT 'PENDING',
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL
);

-------------------------  Customers Audit -------------------------------------------

CREATE OR REPLACE FUNCTION process_cust_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Customer', 'DELETE', OLD."customer_id", user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Customer', 'UPDATE', NEW."customer_id", user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Customer', 'INSERT', NEW."customer_id", user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER cust_audit
AFTER INSERT OR UPDATE OR DELETE ON Customers
FOR EACH ROW EXECUTE PROCEDURE process_cust_audit();

---------------------- Employees Audit -----------------------------------------------

CREATE OR REPLACE FUNCTION process_emp_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Employees', 'DELETE', OLD."employee_id", user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Employees', 'UPDATE', NEW."employee_id", user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Employees', 'INSERT', NEW."employee_id", user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON Employees
FOR EACH ROW EXECUTE PROCEDURE process_emp_audit();

---------------------------- MenuItems Audit ------------------------------------------------

CREATE OR REPLACE FUNCTION process_menu_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('MenuItems', 'DELETE', OLD."item_id", user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('MenuItems', 'UPDATE', NEW."item_id", user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('MenuItems', 'INSERT', NEW."item_id", user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER menu_audit
AFTER INSERT OR UPDATE OR DELETE ON MenuItems
FOR EACH ROW EXECUTE PROCEDURE process_menu_audit();

------------------------------ Orders Audit -----------------------------------------

CREATE OR REPLACE FUNCTION process_order_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Orders', 'DELETE', OLD."order_id", user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Orders', 'UPDATE', NEW."order_id", user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Orders', 'INSERT', NEW."order_id", user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER order_audit
AFTER INSERT OR UPDATE OR DELETE ON Orders
FOR EACH ROW EXECUTE PROCEDURE process_order_audit();

---------------------- Reservations Audit ------------------------------------

CREATE OR REPLACE FUNCTION process_res_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Reservations', 'DELETE', OLD."reservation_id", user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Reservations', 'UPDATE', NEW."reservation_id", user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, row_id, changed_by) values('Reservations', 'INSERT', NEW."reservation_id", user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER res_audit
AFTER INSERT OR UPDATE OR DELETE ON Reservations
FOR EACH ROW EXECUTE PROCEDURE process_res_audit();

--------------------------- CRUD Methods ---------------------------------

--------- SELECT ALL -----------------------
CREATE OR REPLACE FUNCTION getCustomers() 
RETURNS SETOF Customers AS $$
SELECT * FROM Customers;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getEmployees() 
RETURNS SETOF Employees AS $$
SELECT * FROM Employees;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getOrders() 
RETURNS SETOF Orders AS $$
SELECT * FROM Orders;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getOrderItems(int) 
RETURNS SETOF OrderItems AS $$
SELECT * FROM OrderItems WHERE order_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getMenuItems() 
RETURNS SETOF MenuItems AS $$
SELECT * FROM MenuItems;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getReservations() 
RETURNS SETOF Reservations AS $$
SELECT * FROM Reservations;
$$ LANGUAGE SQL;

----------- Specific Updates ---------------
CREATE OR REPLACE FUNCTION serveOrder() 
RETURNS Orders AS $$
UPDATE Orders SET status = 'SERVED' WHERE order_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cancelOrder(int) 
RETURNS Orders AS $$
UPDATE Orders SET status = 'CANCELLED' WHERE order_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION confirmReservation(int) 
RETURNS Reservations AS $$
UPDATE Reservations SET status = 'CONFIRMED' WHERE reservation_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION seatReservation(int) 
RETURNS Reservations AS $$
UPDATE Reservations SET status = 'SEATED' WHERE reservation_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cancelReservation(int) 
RETURNS Reservations AS $$
UPDATE Reservations SET status = 'CANCELLED' WHERE reservation_id = $1;
$$ LANGUAGE SQL;



----------------------- INSERTS ------------------------------------------

insert into Customers(customer_name, phone) values('Chris Kalkas', '6945069188');
insert into Customers(customer_name, phone) values('John Shadow', '6914049168');
insert into Customers(customer_name, phone) values('Maria Savvidou', '6914506938');
insert into Customers(customer_name, phone) values('Kostas Tokkas', '6914506976');
insert into Customers(customer_name, phone) values('Gianni Venturi', '6914506934');
insert into Customers(customer_name, phone) values('Ozzy Osbourne', '6914506467');

insert into Employees(emp_name, emp_role) values('Klavdia Manousaki', 'Host');
insert into Employees(emp_name, emp_role) values('Orestis Zormpas', 'Server');
insert into Employees(emp_name, emp_role) values('Eleni Elenidou', 'Server');
insert into Employees(emp_name, emp_role) values('Akis Petretzikis', 'Cook');
insert into Employees(emp_name, emp_role) values('Dimitris Skarmoutsos', 'Cook');

INSERT INTO MenuItems(item_name, category, price) VALUES('Steak Frites', 'Entree', 25);
INSERT INTO MenuItems(item_name, category, price) VALUES('Burger', 'Entree', 22);
INSERT INTO MenuItems(item_name, category, price) VALUES('Scallops', 'Entree', 20);
INSERT INTO MenuItems(item_name, category, price) VALUES('Beef Wllington', 'Entree', 28);
INSERT INTO MenuItems(item_name, category, price) VALUES('Ceasar Salad', 'Salad', 14);
INSERT INTO MenuItems(item_name, category, price) VALUES('Wedge Salad', 'Salad', 12);
INSERT INTO MenuItems(item_name, category, price) VALUES('Beef Sliders', 'Appetizer', 10);
INSERT INTO MenuItems(item_name, category, price) VALUES('Chicken Sliders', 'Appetizer', 10);
INSERT INTO MenuItems(item_name, category, price) VALUES('Jalapeno Poppers', 'Appetizer', 6);
INSERT INTO MenuItems(item_name, category, price) VALUES('Onion Rings', 'Appetizer', 5);
INSERT INTO MenuItems(item_name, category, price) VALUES('Broccoli Cheddar Soup', 'Appetizer', 12);
INSERT INTO MenuItems(item_name, category, price) VALUES('Cheesecake', 'Dessert', 10);
INSERT INTO MenuItems(item_name, category, price) VALUES('Tiramisu', 'Dessert', 10);
INSERT INTO MenuItems(item_name, category, price) VALUES('White Wine', 'Drink', 6);
INSERT INTO MenuItems(item_name, category, price) VALUES('Red Wine', 'Drink', 6);
INSERT INTO MenuItems(item_name, category, price) VALUES('Beer', 'Drink', 5);
INSERT INTO MenuItems(item_name, category, price) VALUES('Soda', 'Drink', 3);


