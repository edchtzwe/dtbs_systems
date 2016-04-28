SET SERVEROUTPUT ON;
DROP TABLE SALE;
DROP TABLE CUSTOMER;
DROP TABLE PRODUCT;
DROP TABLE LOCATION;

CREATE TABLE CUSTOMER(
  CUSTID NUMBER,
  CUSTNAME VARCHAR2(50),
  STATUS VARCHAR2(7),
  SALES_YTD NUMBER,
  PRIMARY KEY (CUSTID)
);
/

CREATE TABLE PRODUCT (
PRODID	NUMBER
, PRODNAME	VARCHAR2(100)
, SELLING_PRICE	NUMBER
, SALES_YTD	NUMBER
, PRIMARY KEY	(PRODID)
);
/

CREATE TABLE SALE (
SALEID	NUMBER
, CUSTID	NUMBER
, PRODID	NUMBER
, QTY	NUMBER
, PRICE	NUMBER
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);
/

CREATE TABLE LOCATION (
  LOCID	VARCHAR2(5)
, MINQTY	NUMBER
, MAXQTY	NUMBER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LENGTH(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);
/

DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;



CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_TO_DB(pcustid IN NUMBER, pcustname IN VARCHAR2) 
AS
  VALUE_OUT_OF_RANGE EXCEPTION; 
BEGIN  
  IF pcustid BETWEEN 1 AND 499 THEN
    INSERT INTO CUSTOMER(CUSTID, CUSTNAME, SALES_YTD, STATUS)
    VALUES(PCUSTID, PCUSTNAME, 0, 'OK');
  ELSE
    RAISE VALUE_OUT_OF_RANGE;
  END IF;
  
EXCEPTION  
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20001, 'Error: Duplicate customer ID');
  WHEN VALUE_OUT_OF_RANGE THEN
     RAISE_APPLICATION_ERROR(-20002, 'Error: Customer ID out of range ');
  WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20000, 'Error: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_VIASQLDEV(pcustid NUMBER, pcustname VARCHAR2) AS
VALUE_OUT_OF_RANGE EXCEPTION;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Adding Customer. ID: ' || PCUSTID || '   Name: ' || pcustname);
  ADD_CUSTOMER_TO_DB(pcustid, pcustname);
  DBMS_OUTPUT.PUT_LINE('Added OK');
EXCEPTION
  WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION DELETE_ALL_CUSTOMERS_FROM_DB RETURN NUMBER 
AS VCOUNT NUMBER;
BEGIN
  SELECT COUNT(*) INTO VCOUNT
  FROM CUSTOMERS;
  
  DELETE FROM CUSTOMERS;
  
  RETURN VCOUNT;
  
EXCEPTION 
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_CUSTOMERS_VIASQLDEV AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Deleting all Customer rows');
  DBMS_OUTPUT.PUT_LINE(DELETE_ALL_CUSTOMERS_FROM_DB || ' rows deleted');
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_PRODUCT_TO_DB(pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER) AS
ID_OUT_OF_RANGE EXCEPTION;
PRICE_OUT_OF_RANGE EXCEPTION;
BEGIN
  IF(PPRODID BETWEEN 1000 AND 2500) THEN
    IF(PPRICE BETWEEN 0 AND 999.99) THEN
      INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) VALUES(PPRODID, PPRODNAME, PPRICE, 0);
    ELSE
      RAISE PRICE_OUT_OF_RANGE;
    END IF;
  ELSE
    RAISE ID_OUT_OF_RANGE;
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20011, 'Error: Duplicate product ID');
  WHEN ID_OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20012, 'Product ID out of range');
  WHEN PRICE_OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20013, 'Price out of range');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_PRODUCT_VIASQLDEV(pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Adding Product. ID: ' || PPRODID || '   Name: ' || PPRODNAME || '    Price: ' || PPRICE);
  ADD_PRODUCT_TO_DB(PPRODID, PPRODNAME, PPRICE);
  DBMS_OUTPUT.PUT_LINE('Product Added OK');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION DELETE_ALL_PRODUCTS_FROM_DB RETURN NUMBER AS
VCOUNT NUMBER;
BEGIN
  SELECT COUNT(*) INTO VCOUNT FROM PRODUCT;
  
  DELETE FROM PRODUCT;
  
  RETURN VCOUNT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE DELETE_ALL_PRODUCTS_VIASQLDEV AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Deleting all Product rows');
  DBMS_OUTPUT.PUT_LINE(DELETE_ALL_PRODUCTS_FROM_DB || ' rows deleted');  
  COMMIT;
END;
/

CREATE OR REPLACE FUNCTION GET_CUST_STRING_FROM_DB(pcustid NUMBER) RETURN VARCHAR2 AS
VNAME VARCHAR2(50);
VSTAT VARCHAR2(5);
VSYTD NUMBER;
VSTRING VARCHAR(100);
BEGIN
  SELECT CUSTNAME, STATUS, SALES_YTD INTO VNAME, VSTAT, VSYTD FROM CUSTOMER WHERE CUSTID = PCUSTID;
  VSTRING := 'Custid: ' || '  Name:' || VNAME || '  Status: ' || VSTAT || ' SalesYTD: ' || VSYTD;
  
  RETURN VSTRING;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20021, 'Customer ID not found');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE GET_CUST_STRING_VIASQLDEV(pcustid NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Getting Details for CustId ' || PCUSTID);
  DBMS_OUTPUT.PUT_LINE(GET_CUST_STRING_FROM_DB(PCUSTID));
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_SALESYTD_IN_DB(pcustid NUMBER, pamt NUMBER) AS
VALUE_OUT_OF_RANGE EXCEPTION;
VTEMP NUMBER;
BEGIN
  IF(PAMT BETWEEN -999.99 AND 999.99)THEN
    SELECT CUSTID INTO VTEMP FROM CUSTOMER WHERE CUSTID = PCUSTID; --TO TRIGEER NO_DATA_FOUND
    UPDATE CUSTOMER SET SALES_YTD = PAMT WHERE CUSTID = PCUSTID;
  ELSE
    RAISE VALUE_OUT_OF_RANGE;
  END IF;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20031, 'Customer ID not found');
  WHEN VALUE_OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20032, 'Amount out of range');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_SALESYTD_VIASQLDEV(pcustid NUMBER, pamt NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Updating SalesYTD.  Customer Id: ' || PCUSTID || '  Amount: ' || PAMT);
  UPD_CUST_SALESYTD_IN_DB(PCUSTID, PAMT);
  DBMS_OUTPUT.PUT_LINE('Update OK');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION GET_PROD_STRING_FROM_DB(pprodid NUMBER) RETURN VARCHAR2 AS
VSTR VARCHAR2(50);
VNAME VARCHAR2(50);
VPRICE NUMBER;
VSYTD NUMBER;
BEGIN
  SELECT PRODNAME, SELLING_PRICE, SALES_YTD INTO VNAME, VPRICE, VSYTD FROM PRODUCT WHERE PRODID = PPRODID;
  VSTR := 'Prodid: ' || PPRODID || '  Name:' || VNAME || '  Price ' || VPRICE || ' SalesYTD:' || VSYTD;
  
  RETURN VSTR;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20041, 'Product ID not found');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE GET_PROD_STRING_VIASQLDEV(pprodid NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Getting Details for Prod Id ' || PPRODID);
  DBMS_OUTPUT.PUT_LINE(GET_PROD_STRING_FROM_DB(PPRODID));
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_PROD_SALESYTD_IN_DB(pprodid NUMBER, pamt NUMBER) AS
VTEMP NUMBER;
VALUE_OUT_OF_RANGE EXCEPTION;
BEGIN
  IF(PAMT BETWEEN -999.99 AND 999.99) THEN
    SELECT PRODID INTO VTEMP FROM PRODUCT WHERE PRODID = PPRODID; --DATA CHECK
    UPDATE PRODUCT SET SALES_YTD = PAMT WHERE PRODID = PPRODID;
  ELSE
    RAISE VALUE_OUT_OF_RANGE;
  END IF;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20051, 'Product ID not found');
  WHEN VALUE_OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20052, 'Amount out of range');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_PROD_SALESYTD_VIASQLDEV(pprodid NUMBER, PAMT NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Updating SalesYTD   Product Id: ' || PPRODID || '  Amount: ' || PAMT);
  UPD_PROD_SALESYTD_IN_DB(PPRODID, PAMT);
  DBMS_OUTPUT.PUT_LINE('Update OK');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_STATUS_IN_DB(PCUSTID NUMBER, PSTATUS VARCHAR2) AS
INVALID_STATUS EXCEPTION;
VTEMP NUMBER;
BEGIN  
  IF(UPPER(PSTATUS) != 'OK' AND UPPER(PSTATUS) != 'SUSPEND') THEN
    RAISE INVALID_STATUS;
  END IF;
  SELECT CUSTID INTO VTEMP FROM CUSTOMER WHERE CUSTID = PCUSTID; --TO TRIGEER NO_DATA_FOUND
  UPDATE CUSTOMER SET STATUS = PSTATUS WHERE CUSTID = PCUSTID;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20061, 'Customer ID not found');
  WHEN INVALID_STATUS THEN
    RAISE_APPLICATION_ERROR(-20062, 'Invalid Status value');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE UPD_CUST_STATUS_VIASQLDEV(pcustid NUMBER, PSTATUS VARCHAR2) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Updating Status.  Id: ' || PCUSTID || '  New Status: ' || PSTATUS);
  UPD_CUST_STATUS_IN_DB(PCUSTID, PSTATUS);
  DBMS_OUTPUT.PUT_LINE('Update OK');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_SIMPLE_SALE_TO_DB(PCUSTID NUMBER, PPRODID NUMBER, PQTY NUMBER) AS
INVALID_CUSTOMER_STATUS EXCEPTION;
VALUE_OUT_OF_RANGE EXCEPTION;
CUSTOMER_NOT_FOUND EXCEPTION;
PRODUCT_NOT_FOUND EXCEPTION;
VSTAT VARCHAR2(7);
VYTD NUMBER;
VPRICE NUMBER;
VTEMP NUMBER;
BEGIN
  SELECT COUNT(*) INTO VTEMP FROM CUSTOMER WHERE PCUSTID = CUSTID;
  IF(VTEMP < 1)THEN
    RAISE CUSTOMER_NOT_FOUND;
  END IF;
  SELECT COUNT(*) INTO VTEMP FROM PRODUCT WHERE PPRODID = PRODID;
  IF(VTEMP < 1)THEN
    RAISE PRODUCT_NOT_FOUND;
  END IF;
  IF(UPPER(VSTAT) != 'OK')THEN
    RAISE INVALID_CUSTOMER_STATUS;
  END IF;
  IF(PQTY NOT BETWEEN 1 AND 999)THEN
    RAISE VALUE_OUT_OF_RANGE;
  END IF;
  
  SELECT SELLING_PRICE INTO VPRICE FROM PRODUCT WHERE PRODID = PPRODID;
  VYTD := PQTY * VPRICE;
  UPD_CUST_SALESYTD_IN_DB(PCUSTID, VYTD);
  UPD_PROD_SALESYTD_IN_DB(PPRODID, VYTD);
  
EXCEPTION
  WHEN VALUE_OUT_OF_RANGE THEN
    RAISE_APPLICATION_ERROR(-20071, 'Sale Quantity outside valid range');
  WHEN INVALID_CUSTOMER_STATUS THEN
    RAISE_APPLICATION_ERROR(-20072, 'Customer status is not OK');
  WHEN CUSTOMER_NOT_FOUND THEN
    RAISE_APPLICATION_ERROR(-20073, 'Customer ID not found');
  WHEN PRODUCT_NOT_FOUND THEN
    RAISE_APPLICATION_ERROR(-20074, 'Product ID not found');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_SIMPLE_SALE_VIASQLDEV(PCUSTID NUMBER, PPRODID NUMBER, PQTY NUMBER) AS
VSTAT VARCHAR2(7);
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Adding Simple Sale. Cust Id: ' || PCUSTID || ' Prod Id ' || PPRODID ||  'Qty: ' || PQTY);
  ADD_SIMPLE_SALE_TO_DB(PCUSTID, PPRODID, PQTY);
  DBMS_OUTPUT.PUT_LINE('Added Simple Sale OK');
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION SUM_PROD_SALESYTD_FROM_DB RETURN NUMBER AS
VTEMP NUMBER := 0;
BEGIN
  SELECT SUM(SALES_YTD) INTO VTEMP FROM PRODUCT;
  
  RETURN VTEMP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE SUM_PROD_SALES_VIASQLDEV AS
VTEMP NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Summing Product SalesYTD');
  VTEMP := SUM_PROD_SALESYTD_FROM_DB();
  IF(VTEMP IS NULL)THEN
    RAISE NO_DATA_FOUND;
  END IF;
  DBMS_OUTPUT.PUT_LINE('All Product Total: ' || VTEMP);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('All Product Total: 0');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

----------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GET_ALLCUST_FROM_DB RETURN SYS_REFCURSOR AS
REFCUR SYS_REFCURSOR;
BEGIN
  OPEN REFCUR FOR SELECT * FROM CUSTOMER;
  
  RETURN REFCUR;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE GET_ALLCUST_VIASQLDEV AS
REFCUR SYS_REFCURSOR;
VID CUSTOMER.CUSTID%TYPE;
VNAME CUSTOMER.CUSTNAME%TYPE;
VSTAT CUSTOMER.STATUS%TYPE;
VSALESYTD CUSTOMER.SALES_YTD%TYPE;
VTEMP NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Listing All Customer Details');
  REFCUR := GET_ALLCUST_FROM_DB;
  SELECT COUNT(*) INTO VTEMP FROM CUSTOMER;
  IF(VTEMP = 0)THEN
    RAISE NO_DATA_FOUND;
  END IF;
  LOOP
    FETCH REFCUR INTO VID, VNAME, VSTAT, VSALESYTD;
    EXIT WHEN REFCUR%NOTFOUND;   
    DBMS_OUTPUT.PUT_LINE('Custid: ' || VID || 'Name:' || VNAME || 'Status ' || VSTAT || 'SalesYTD:' || VSALESYTD);
  END LOOP;
  CLOSE REFCUR;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NO ROWS FOUND');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION GET_ALLPROD_FROM_DB RETURN SYS_REFCURSOR AS
REFCUR SYS_REFCURSOR;
BEGIN
  OPEN REFCUR FOR SELECT * FROM PRODUCT;
  
  RETURN REFCUR;
EXCEPTION 
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE GET_ALLPROD_VIASQLDEV AS
REFCUR SYS_REFCURSOR;
VID PRODUCT.PRODID%TYPE;
VNAME PRODUCT.PRODNAME%TYPE;
VPRICE PRODUCT.SELLING_PRICE%TYPE;
VSALESYTD PRODUCT.SALES_YTD%TYPE;
VTEMP NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Listing All Product Details');
  REFCUR := GET_ALLPROD_FROM_DB;
  SELECT COUNT(*) INTO VTEMP FROM PRODUCT;
  IF(VTEMP = 0)THEN
    RAISE NO_DATA_FOUND;
  END IF;
  LOOP
    FETCH REFCUR INTO VID, VNAME, VPRICE, VSALESYTD;
    EXIT WHEN REFCUR%NOTFOUND;   
    DBMS_OUTPUT.PUT_LINE('Prodid: ' || VID || ' Name:' || VNAME || ' Price ' || VPRICE || ' SalesYTD:' || VSALESYTD);
  END LOOP;
  CLOSE REFCUR;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NO ROWS FOUND');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--FROM LECTURE NOTES
CREATE OR REPLACE FUNCTION strip_constraint(pErrmsg VARCHAR2 )RETURN VARCHAR2 AS
rp_loc NUMBER; 
dot_loc NUMBER;
-- The constraint name is between the location of the first '.'
-- and the location of the first ')'
BEGIN
  dot_loc := INSTR(pErrmsg , '.');  -- find the dot
  rp_loc := INSTR(pErrmsg , ')');  -- find the bracket
  IF (dot_loc = 0 OR rp_loc = 0 ) THEN 
    RETURN NULL ;
  ELSE  
    RETURN UPPER(SUBSTR(pErrmsg,dot_loc+1,rp_loc-dot_loc-1));
  END IF;
END;
/

CREATE OR REPLACE PROCEDURE ADD_LOCATION_TO_DB(PLOCCODE VARCHAR2, PMINQTY NUMBER, PMAXQTY NUMBER) AS
VTEMP VARCHAR2(240);
BEGIN
  INSERT INTO LOCATION VALUES(PLOCCODE, PMINQTY, PMAXQTY);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20081, 'Duplicate location ID');
  WHEN OTHERS THEN 
    VTEMP := STRIP_CONSTRAINT(SQLERRM);
    IF(VTEMP = 'CHECK_MAXQTY_GREATER_MIXQTY')THEN
      RAISE_APPLICATION_ERROR(-20085, 'Minimum Qty larger than Maximum Qty');
    ELSIF(VTEMP = 'CHECK_LOCID_LENGTH')THEN
      RAISE_APPLICATION_ERROR(-20082, 'Location Code length invalid');
    ELSIF(VTEMP = 'CHECK_MINQTY_RANGE')THEN
      RAISE_APPLICATION_ERROR(-20083, 'Minimum Qty out of range');
    ELSIF(VTEMP = 'CHECK_MAXQTY_RANGE')THEN
      RAISE_APPLICATION_ERROR(-20084, 'Maximum Qty out of range');
    ELSE
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    END IF;    
END;
/

CREATE OR REPLACE PROCEDURE ADD_LOCATION_VIASQLDEV(PLOCCODE VARCHAR2, PMINQTY NUMBER, PMAXQTY NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Adding Location   LocCode: ' || PLOCCODE || ' MinQty: ' || PMINQTY || 'MaxQty: ' || PMAXQTY);
  ADD_LOCATION_TO_DB(PLOCCODE, PMINQTY, PMAXQTY);
  DBMS_OUTPUT.PUT_LINE('Location Added OK');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE ADD_COMPLEX_SALE_TO_DB(PCUSTID NUMBER, PPRODID NUMBER, PQTY NUMBER, PDATE VARCHAR2) AS
INVALID_CUSTOMER_STATUS EXCEPTION;
INVALID_SALE_QTY_RANGE EXCEPTION;
CUSTOMER_ID_NOT_FOUND EXCEPTION;
PRODUCT_ID_NOT_FOUND EXCEPTION; 
VSTATUS VARCHAR2(7);
VDATE DATE;
VPRICE NUMBER;
VTEMP NUMBER;
BEGIN
  VDATE := TO_DATE(PDATE, 'yyyymmdd');
  SELECT COUNT(*) INTO VTEMP FROM CUSTOMER WHERE CUSTID = PCUSTID;
  IF(VTEMP < 1)THEN
    RAISE CUSTOMER_ID_NOT_FOUND;
  END IF;
  SELECT COUNT(*) INTO VTEMP FROM PRODUCT WHERE PRODID = PPRODID;
  IF(VTEMP < 1) THEN
    RAISE PRODUCT_ID_NOT_FOUND;
  END IF;
  SELECT STATUS INTO VSTATUS FROM CUSTOMER WHERE CUSTID = PCUSTID;
  SELECT SELLING_PRICE INTO VPRICE FROM PRODUCT WHERE PRODID = PPRODID;
  IF(UPPER(VSTATUS) != 'OK')THEN
    RAISE INVALID_CUSTOMER_STATUS;
  ELSIF(PQTY NOT BETWEEN 1 AND 999)THEN
    RAISE INVALID_SALE_QTY_RANGE;  
  END IF;
  
  INSERT INTO SALE VALUES(SALE_SEQ.NEXTVAL, PCUSTID, PPRODID, PQTY, VPRICE, VDATE);
  UPD_CUST_SALESYTD_IN_DB(PCUSTID, PQTY * VPRICE);
  UPD_PROD_SALESYTD_IN_DB(PPRODID, PQTY * VPRICE);
  
EXCEPTION
  WHEN INVALID_CUSTOMER_STATUS THEN
    RAISE_APPLICATION_ERROR(-20092, 'Customer status is not OK');
  WHEN INVALID_SALE_QTY_RANGE THEN
    RAISE_APPLICATION_ERROR(-20091, 'Sale Quantity outside valid range');
  WHEN CUSTOMER_ID_NOT_FOUND THEN
    RAISE_APPLICATION_ERROR(-20094, 'Customer ID not found');
  WHEN PRODUCT_ID_NOT_FOUND THEN
    RAISE_APPLICATION_ERROR(-20095, 'Product ID not found');
  WHEN OTHERS THEN
    IF(SQLCODE = -01841 OR SQLCODE = -01858 OR SQLCODE = -01843 OR SQLCODE = -01847)THEN
      RAISE_APPLICATION_ERROR(-20093, 'Date not valid');
    ELSIF(SQLCODE = -06512)THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    ELSE
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ADD_COMPLEX_SALE_VIASQLDEV(PCUSTID NUMBER, PPRODID NUMBER, PQTY NUMBER, PDATE VARCHAR2) AS
VTEMP NUMBER;
BEGIN
  SELECT SELLING_PRICE INTO VTEMP FROM PRODUCT WHERE PRODID = PPRODID;
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Adding Complex Sale. Cust Id: ' || PCUSTID || ' Prod Id ' || PPRODID || ' Date: ' || PDATE || ' Amt: ' || PQTY*VTEMP);
  ADD_COMPLEX_SALE_TO_DB(PCUSTID, PPRODID, PQTY, PDATE);
  DBMS_OUTPUT.PUT_LINE('Added Complex Sale OK');  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('PRODUCT NOT FOUND');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION GET_ALLSALES_FROM_DB RETURN SYS_REFCURSOR AS
REFCUR SYS_REFCURSOR;
BEGIN
   OPEN REFCUR FOR SELECT * FROM SALE;
  
  RETURN REFCUR;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE GET_ALLSALES_VIASQLDEV AS
REFCUR SYS_REFCURSOR;
VSALEID SALE.SALEID%TYPE;
VCUSTID SALE.CUSTID%TYPE;
VPRODID SALE.PRODID%TYPE;
VQTY SALE.QTY%TYPE;
VPRICE SALE.PRICE%TYPE;
VDATE SALE.SALEDATE%TYPE;
VTEMP NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Listing All Complex Sales Details');
  REFCUR := GET_ALLSALES_FROM_DB;
  SELECT COUNT(*) INTO VTEMP FROM SALE;
  IF(VTEMP = 0)THEN
    RAISE NO_DATA_FOUND;
  END IF;
  LOOP
    FETCH REFCUR INTO VSALEID, VCUSTID, VPRODID, VQTY, VPRICE, VDATE;
    EXIT WHEN REFCUR%NOTFOUND;   
    DBMS_OUTPUT.PUT_LINE('Saleid: ' || VSALEID || ' Custid: ' || VCUSTID || ' Prodid: ' || VPRODID || '  Date ' || VDATE || '  Amount: ' || VPRICE);
  END LOOP;
  CLOSE REFCUR;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('NO ROWS FOUND');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

CREATE OR REPLACE FUNCTION COUNT_PRODUCT_SALES_FROM_DB(PDAYS NUMBER) RETURN NUMBER AS
VCOUNT NUMBER;
VDAY NUMBER;
VDATE DATE;
REFCUR SYS_REFCURSOR;
BEGIN
  VCOUNT := 0;
  OPEN REFCUR FOR SELECT SALEDATE FROM SALE;
  LOOP
    FETCH REFCUR INTO VDATE;
    VDAY := EXTRACT(DAY FROM VDATE);
    IF(VDAY = PDAYS)THEN
      VCOUNT := VCOUNT + 1;
    END IF;
  END LOOP;
  CLOSE REFCUR;
  RETURN VCOUNT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE COUNT_PRODUCT_SALES_VIASQLDEV(PDAYS NUMBER) AS
VCOUNT NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Counting sales within ' || PDAYS || ' days');
  VCOUNT := COUNT_PRODUCT_SALES_FROM_DB(PDAYS);
  DBMS_OUTPUT.PUT_LINE('Total number of sales: ' || VCOUNT);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/







--TEST ONE
begin 
dbms_output.put_line('Student ID: 7440820'); 
DELETE * FROM SALE;
DELETE_ALL_CUSTOMERS_VIASQLDEV; 
DELETE_ALL_PRODUCTS_VIASQLDEV; 
dbms_output.put_line('==========TEST ADD CUSTOMERS =========================='); 
ADD_CUSTOMER_VIASQLDEV(1,'Colin Smith'); 
ADD_CUSTOMER_VIASQLDEV(2,'Jill Davis'); 
ADD_CUSTOMER_VIASQLDEV(3,'Dave Brown'); 
ADD_CUSTOMER_VIASQLDEV(4,'Kirsty Glass'); 
ADD_CUSTOMER_VIASQLDEV(1,'Jenny Nighy'); 
ADD_CUSTOMER_VIASQLDEV(-3,'Emma Jones'); 
ADD_CUSTOMER_VIASQLDEV(666,'Peter White'); 
dbms_output.put_line('==========TEST ADD PRODUCTS=========================='); 
ADD_PRODUCT_VIASQLDEV(1001,'ProdA', 10); 
ADD_PRODUCT_VIASQLDEV(1002,'ProdB', 20); 
ADD_PRODUCT_VIASQLDEV(1003,'ProdC', 35); 
ADD_PRODUCT_VIASQLDEV(1001,'ProdD', 10); 
ADD_PRODUCT_VIASQLDEV(3333,'ProdD', 100); 
ADD_PRODUCT_VIASQLDEV(1004,'ProdD', 1234); 
dbms_output.put_line('===========TEST STATUS UPDATES =========================='); 
UPD_CUST_STATUS_VIASQLDEV(3,'SUSPEND'); 
UPD_CUST_STATUS_VIASQLDEV(4,'QWERTY'); 
dbms_output.put_line('===========TEST CUSTOMER RETREIVAL =========================='); 
GET_CUST_STRING_VIASQLDEV(1); 
GET_CUST_STRING_VIASQLDEV(2); 
GET_CUST_STRING_VIASQLDEV(22); 
dbms_output.put_line('===========TEST CUSTOMER RETREIVAL =========================='); 
GET_PROD_STRING_VIASQLDEV(1001); 
GET_PROD_STRING_VIASQLDEV(1002); 
GET_PROD_STRING_VIASQLDEV(2222); 
dbms_output.put_line('===========TEST SIMPLE SALES =========================='); 
ADD_SIMPLE_SALE_VIASQLDEV(1,1001,15); 
ADD_SIMPLE_SALE_VIASQLDEV(2,1002,37); 
ADD_SIMPLE_SALE_VIASQLDEV(3,1002,15); 
ADD_SIMPLE_SALE_VIASQLDEV(4,1001,100); 
SUM_CUST_SALES_VIASQLDEV; 
SUM_PROD_SALES_VIASQLDEV; 
dbms_output.put_line('===========MORE TESTING OF SIMPLE SALES =========================='); 
ADD_SIMPLE_SALE_VIASQLDEV(99,1002,60); 
ADD_SIMPLE_SALE_VIASQLDEV(2,5555,60); 
ADD_SIMPLE_SALE_VIASQLDEV(1,1002,6666); 
SUM_CUST_SALES_VIASQLDEV; 
SUM_PROD_SALES_VIASQLDEV; 
dbms_output.put_line('==========LIST ALL CUSTOMERS AND PRODUCTS=========================='); 
GET_CUST_STRING_VIASQLDEV(1); 
GET_CUST_STRING_VIASQLDEV(2); 
GET_CUST_STRING_VIASQLDEV(3); 
GET_CUST_STRING_VIASQLDEV(4); 
GET_PROD_STRING_VIASQLDEV(1001); 
GET_PROD_STRING_VIASQLDEV(1002); 
GET_PROD_STRING_VIASQLDEV(1003); 
end; 
/

--TEST TWO
begin 
dbms_output.put_line('Student ID: 7440820'); 
dbms_output.put_line('==========PART 2 TEST CURSOR=========================='); 
GET_ALLCUST_VIASQLDEV; 
GET_ALLPROD_VIASQLDEV; 
end; 
/


--TEST THREE
begin 
dbms_output.put_line('Student ID: 7440820'); 
dbms_output.put_line('==========PART 3 TEST LOCATIONS=========================='); 
ADD_LOCATION_VIASQLDEV ('AF201',1,2); 
ADD_LOCATION_VIASQLDEV ('AF202',-3,4); 
ADD_LOCATION_VIASQLDEV ('AF203',5,1); 
ADD_LOCATION_VIASQLDEV ('AF204',6,7000); 
ADD_LOCATION_VIASQLDEV ('AF20111',8,9); 
end; 
/

--TEST FOUR
BEGIN
ADD_CUSTOMER_VIASQLDEV(10,'Mieko Hayashi'); 
ADD_CUSTOMER_VIASQLDEV(11,'John Kalia'); 
ADD_CUSTOMER_VIASQLDEV(12,'Alex Kim'); 
ADD_PRODUCT_VIASQLDEV(2001,'Chair', 10); 
ADD_PRODUCT_VIASQLDEV(2002,'Table', 45); 
ADD_PRODUCT_VIASQLDEV(2003,'Lamp', 22); 
ADD_COMPLEX_SALE_VIASQLDEV (10,2001,6,'20140301'); 
ADD_COMPLEX_SALE_VIASQLDEV (10,2002,1,'20140320'); 
ADD_COMPLEX_SALE_VIASQLDEV (11,2001,1,'20140301'); 
ADD_COMPLEX_SALE_VIASQLDEV (11,2003,2,'20140215'); 
ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'20140131'); 
COUNT_PRODUCT_SALES_VIASQLDEV( sysdate-to_date('01-Jan-2014')); 
COUNT_PRODUCT_SALES_VIASQLDEV( sysdate-to_date('01-Feb-2014')); 
GET_ALLSALES_VIASQLDEV; 
ADD_COMPLEX_SALE_VIASQLDEV (99,2001,10,'20140131'); 
ADD_COMPLEX_SALE_VIASQLDEV (12,9999,10,'20140131'); 
ADD_COMPLEX_SALE_VIASQLDEV (12,2001,9999,'20140131'); 
ADD_COMPLEX_SALE_VIASQLDEV (12,2001,10,'99999999'); 
UPD_CUST_STATUS_VIASQLDEV(12,'SUSPEND'); 
ADD_COMPLEX_SALE_VIASQLDEV (12,2002,10,'20140131'); 
END;
/