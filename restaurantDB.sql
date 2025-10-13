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

----- Customers

-- Create Customer
CREATE OR REPLACE PROCEDURE add_customer(
in_customer_name VARCHAR(255),
in_phone VARCHAR(100))
AS $$
  INSERT INTO customers(customer_name, phone) VALUES(in_customer_name,in_phone)
$$ LANGUAGE SQL;

-- Update Customer
CREATE OR REPLACE PROCEDURE update_customer(
in_customer_id INT,
in_customer_name VARCHAR(255),
in_phone VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customers SET(customer_name, phone) = (in_customer_name,in_phone)
  WHERE customer_id = in_customer_id;
END; $$;

-- Delete Customer
CREATE OR REPLACE PROCEDURE delete_customer(
in_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM customers WHERE customer_id=in_id;
END; $$;

---- Employees

-- Create Employee
CREATE OR REPLACE PROCEDURE add_employee(
in_emp_name VARCHAR(255),
in_emp_role role_type)
AS $$
  INSERT INTO employees(emp_name, emp_role) VALUES(in_emp_name,in_emp_role)
$$ LANGUAGE SQL;

-- Update Employee
CREATE OR REPLACE PROCEDURE update_employee(
in_employee_id INT,
in_emp_name VARCHAR(255),
in_emp_role role_type
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE employees SET(emp_name, emp_role) = (in_emp_name,in_emp_role)
  WHERE employee_id = in_employee_id;
END; $$;

-- Delete Employee
CREATE OR REPLACE PROCEDURE delete_employee(
in_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM employees WHERE employee_id=in_id;
END; $$;


------ Orders

-- Create Order
CREATE OR REPLACE PROCEDURE create_order(
  in_customer_id INT,
  in_employee_id INT)
AS $$
  INSERT INTO orders(customer_id, employee_id) VALUES(in_customer_id,in_employee_id)
$$ LANGUAGE SQL;

-- Update Order Status
CREATE OR REPLACE PROCEDURE update_order_status(
in_order_id INT, in_status order_status_type)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE orders SET status=in_status WHERE order_id=in_order_id;
END; $$;

-- Delete Order
CREATE OR REPLACE PROCEDURE delete_order(
in_order_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM orders WHERE id=in_order_id;
END; $$;


-- Add Order Item
CREATE OR REPLACE PROCEDURE add_order_item(
  in_order_id INT,
  in_item_id INT,
  in_qty INT
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO orderItems(order_id,item_id,quantity)
  VALUES(in_order_id,in_menuitem_id,in_qty);

  UPDATE orders SET total = (
  	SELECT sum(o.quantity*m.price) 
	FROM orderItems o INNER JOIN menuItems m ON o.item_id = m.item_id
  ) WHERE order_id = in_order_id;
END; $$;


-- Add Reservation
CREATE OR REPLACE PROCEDURE add_reservation(
  in_customer_id INT,
  in_num_people INT)
AS $$
  INSERT INTO reservations(customer_id,num_people) VALUES(in_customer_id,in_num_people)
$$ LANGUAGE SQL;


-- Update Reservation Status
CREATE OR REPLACE PROCEDURE update_reservation_status(
in_reservation_id INT, in_status reservation_status_type)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE reservations SET status=in_status WHERE reservation_id=in_reservation_id;
END; $$;


-- Add Menu Items
CREATE OR REPLACE PROCEDURE add_menuitem(
  in_name VARCHAR,
  in_category category_type,
  in_price INT)
AS $$
  INSERT INTO menuitems(item_name,category,price) VALUES(in_name,in_category,in_price)
$$ LANGUAGE SQL;

-- Update Menu Item
CREATE OR REPLACE PROCEDURE update_menuitem(
  in_id INT,
  in_name VARCHAR,
  in_category category_type,
  in_price NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE menuitems SET item_name=in_name, category=in_category, price=in_price WHERE item_id=in_id;
END; $$;

-- Delete Menu Item
CREATE OR REPLACE PROCEDURE delete_menuitem(
in_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM menuitems WHERE item_id=in_id;
END; $$;


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
RETURNS TABLE (
	item_name VARCHAR(100),
	quantity INT,
	subtotal INT)
AS $$
	SELECT m.item_name, o.quantity, m.price*o.quantity AS subtotal
	FROM OrderItems o INNER JOIN MenuItems m ON o.item_id = m.item_id 
	WHERE order_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getMenuItems() 
RETURNS SETOF MenuItems AS $$
SELECT * FROM MenuItems;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getReservations() 
RETURNS SETOF Reservations AS $$
SELECT * FROM Reservations;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getAuditLog() 
RETURNS SETOF AuditLog AS $$
SELECT * FROM AuditLog 
ORDER BY change_time DESC;
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

INSERT INTO Orders (customer_id, employee_id) values (13, 7);
INSERT INTO Orders (customer_id, employee_id) values (14, 8);
INSERT INTO Orders (customer_id, employee_id) values (15, 7);
INSERT INTO Orders (customer_id, employee_id) values (16, 8);
INSERT INTO Orders (customer_id, employee_id) values (17, 7);
INSERT INTO Orders (customer_id, employee_id) values (18, 8);
INSERT INTO Orders (customer_id, employee_id) values (19, 7);

INSERT INTO Reservations (customer_id, num_people) values (13, 4);
INSERT INTO Reservations (customer_id, num_people) values (14, 4);
INSERT INTO Reservations (customer_id, num_people) values (15, 3);
INSERT INTO Reservations (customer_id, num_people) values (16, 2);
INSERT INTO Reservations (customer_id, num_people) values (17, 5);
INSERT INTO Reservations (customer_id, num_people) values (18, 3);
INSERT INTO Reservations (customer_id, num_people) values (19, 2);




-------------------------- SELECT IDEAS -----------------------

---- Show Specific Order Items ---------
select m.item_name Items, quantity Quantity from menuItems m INNER JOIN orderItems o ON m.item_id = o.item_id;