CREATE TABLE AuditLog (
	log_id INT generated always as identity PRIMARY KEY,
	name_table VARCHAR(100) NOT NULL,
	operation VARCHAR(10) CHECK (operation in ('INSERT', 'UPDATE', 'DELETE')),
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
	emp_role VARCHAR(10) CHECK (emp_role in ('Server', 'Host', 'Cook'))
);


CREATE TABLE MenuItems(
	item_id INT generated always as identity PRIMARY KEY,
	item_name VARCHAR(100) NOT NULL,
	category VARCHAR(10) CHECK (category in ('Appetizer','Entree','Salad','Dessert','Drink')),
	price INT
);

CREATE TABLE Orders(
	order_id INT generated always as identity PRIMARY KEY,
	customer_id INT,
	employee_id INT,
	order_date  timestamp DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR(10) CHECK (status in ('IN_PROGRESS','SERVED','CANCELLED')) DEFAULT 'IN_PROGRESS',
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
	status VARCHAR(10) CHECK (status in ('PENDING','CONFIRMED','CANCELLED','SEATED')) DEFAULT 'PENDING',
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL
);

-------------------------  Customers Audit -------------------------------------------

CREATE OR REPLACE FUNCTION process_cust_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Customer', 'DELETE', OLD.customer_id, user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Customer', 'UPDATE', NEW.customer_id, user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Customer', 'INSERT', NEW.customer_id, user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER cust_audit
AFTER INSERT OR UPDATE OR DELETE ON Customer
FOR EACH ROW EXECUTE PROCEDURE process_cust_audit();

---------------------- Employees Audit -----------------------------------------------

CREATE OR REPLACE FUNCTION process_emp_audit()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Employees', 'DELETE', OLD.employee_id, user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Employees', 'UPDATE', NEW.employee_id, user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Employees', 'INSERT', NEW.employee_id, user);
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
	INSERT INTO auditLog(name_table, operation, changed_by) values('MenuItems', 'DELETE', OLD.item_id, user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('MenuItems', 'UPDATE', NEW.item_id, user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('MenuItems', 'INSERT', NEW.item_id, user);
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
	INSERT INTO auditLog(name_table, operation, changed_by) values('Orders', 'DELETE', OLD.order_id, user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Orders', 'UPDATE', NEW.order_id, user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Orders', 'INSERT', NEW.order_id, user);
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
	INSERT INTO auditLog(name_table, operation, changed_by) values('Reservations', 'DELETE', OLD.reservation_id, user);
	RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Reservations', 'UPDATE', NEW.reservation_id, user);
	RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
	INSERT INTO auditLog(name_table, operation, changed_by) values('Reservations', 'INSERT', NEW.reservation_id, user);
	RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER res_audit
AFTER INSERT OR UPDATE OR DELETE ON Reservations
FOR EACH ROW EXECUTE PROCEDURE process_res_audit();

--------------------------- CRUD ---------------------------------

