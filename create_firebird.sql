/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database creation script                        */
/* Created on:            2021-03-07 20:38                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Add sequences                                                          */
/* ---------------------------------------------------------------------- */

CREATE GENERATOR GEN_HILO;
SET GENERATOR GEN_HILO TO 0;

/* ---------------------------------------------------------------------- */
/* Add domains                                                            */
/* ---------------------------------------------------------------------- */

CREATE DOMAIN DOM_TXN_TYPE AS CHAR(5) CHARACTER SET UTF8;

/* ---------------------------------------------------------------------- */
/* Add tables                                                             */
/* ---------------------------------------------------------------------- */

/* ---------------------------------------------------------------------- */
/* Add table "PRODUCT_CATEGORY"                                           */
/* ---------------------------------------------------------------------- */

CREATE TABLE PRODUCT_CATEGORY (
    PRODUCT_CATEGORY_ID INTEGER NOT NULL,
    PRODUCT_CATEGORY_NAME VARCHAR(80) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    VISUAL_SEQ INTEGER,
    IS_SYSTEM INTEGER,
    CONSTRAINT PK_PRODUCT_CATEGORY PRIMARY KEY (PRODUCT_CATEGORY_ID),
    CONSTRAINT UNQ_PRODUCT_CATEGORY_1 UNIQUE (PRODUCT_CATEGORY_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "LOCATION"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE LOCATION (
    LOCATION_ID INTEGER NOT NULL,
    LOCATION_NAME VARCHAR(80) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    IS_SYSTEM INTEGER,
    CONSTRAINT PK_LOCATION PRIMARY KEY (LOCATION_ID),
    CONSTRAINT UNQ_LOCATION_1 UNIQUE (LOCATION_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "MOVEMENT_TYPE"                                              */
/* ---------------------------------------------------------------------- */

CREATE TABLE MOVEMENT_TYPE (
    MOVEMENT_TYPE_ID DOM_TXN_TYPE NOT NULL,
    MOVEMENT_TYPE_NAME CHARACTER(40) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    DIRECTION INTEGER,
    IS_SYSTEM INTEGER,
    CONSTRAINT PK_MOVEMENT_TYPE PRIMARY KEY (MOVEMENT_TYPE_ID),
    CONSTRAINT UNQ_MOVEMENT_TYPE_1 UNIQUE (MOVEMENT_TYPE_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "DEPARTMENT"                                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE DEPARTMENT (
    DEPARTMENT_ID INTEGER NOT NULL,
    DEPARTMENT_NAME VARCHAR(80) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    IS_SYSTEM INTEGER,
    CONSTRAINT PK_DEPARTMENT PRIMARY KEY (DEPARTMENT_ID),
    CONSTRAINT UNQ_DEPARTMENT_1 UNIQUE (DEPARTMENT_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "PRODUCT"                                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE PRODUCT (
    PRODUCT_ID INTEGER NOT NULL,
    PRODUCT_NAME VARCHAR(80) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    UNIT_MEASURE VARCHAR(20) CHARACTER SET UTF8 COLLATE UTF8,
    PRODUCT_CATEGORY_ID INTEGER NOT NULL,
    CONSTRAINT PK_PRODUCT PRIMARY KEY (PRODUCT_ID),
    CONSTRAINT UNQ_PRODUCT_1 UNIQUE (PRODUCT_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "EMPLOYEE"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE EMPLOYEE (
    EMPLOYEE_ID INTEGER NOT NULL,
    EMPLOYEE_NAME VARCHAR(80) CHARACTER SET UTF8 NOT NULL COLLATE UTF8,
    DEPARTMENT_ID INTEGER NOT NULL,
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EMPLOYEE_ID),
    CONSTRAINT UNQ_EMPLOYEE_1 UNIQUE (EMPLOYEE_NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "MOVEMENT"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE MOVEMENT (
    MOVEMENT_ID INTEGER NOT NULL,
    MOVEMENT_DATE DATE,
    DOC_NUMBER VARCHAR(20) CHARACTER SET UTF8 COLLATE UTF8,
    QTY_IN NUMERIC(15,4),
    QTY_OUT NUMERIC(15,4),
    EMPLOYEE_ID INTEGER NOT NULL,
    DEPARTMENT_ID INTEGER NOT NULL,
    PRODUCT_ID INTEGER NOT NULL,
    LOCATION_ID INTEGER NOT NULL,
    MOVEMENT_TYPE_ID CHAR(5) CHARACTER SET UTF8 NOT NULL,
    CONSTRAINT PK_MOVEMENT PRIMARY KEY (MOVEMENT_ID)
);

/* ---------------------------------------------------------------------- */
/* Add foreign key constraints                                            */
/* ---------------------------------------------------------------------- */

ALTER TABLE PRODUCT ADD CONSTRAINT PRODUCT_CATEGORY_PRODUCT 
    FOREIGN KEY (PRODUCT_CATEGORY_ID) REFERENCES PRODUCT_CATEGORY (PRODUCT_CATEGORY_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT EMPLOYEE_MOVEMENT 
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE (EMPLOYEE_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT DEPARTMENT_MOVEMENT 
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT PRODUCT_MOVEMENT 
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT (PRODUCT_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT LOCATION_MOVEMENT 
    FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION (LOCATION_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT MOVEMENT_TYPE_MOVEMENT 
    FOREIGN KEY (MOVEMENT_TYPE_ID) REFERENCES MOVEMENT_TYPE (MOVEMENT_TYPE_ID);

ALTER TABLE EMPLOYEE ADD CONSTRAINT DEPARTMENT_EMPLOYEE 
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID);
