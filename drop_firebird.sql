/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database drop script                            */
/* Created on:            2021-03-07 20:38                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE PRODUCT DROP CONSTRAINT PRODUCT_CATEGORY_PRODUCT;

ALTER TABLE MOVEMENT DROP CONSTRAINT EMPLOYEE_MOVEMENT;

ALTER TABLE MOVEMENT DROP CONSTRAINT DEPARTMENT_MOVEMENT;

ALTER TABLE MOVEMENT DROP CONSTRAINT PRODUCT_MOVEMENT;

ALTER TABLE MOVEMENT DROP CONSTRAINT LOCATION_MOVEMENT;

ALTER TABLE MOVEMENT DROP CONSTRAINT MOVEMENT_TYPE_MOVEMENT;

ALTER TABLE EMPLOYEE DROP CONSTRAINT DEPARTMENT_EMPLOYEE;

/* ---------------------------------------------------------------------- */
/* Drop table "MOVEMENT"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE MOVEMENT DROP CONSTRAINT PK_MOVEMENT;

DROP TABLE MOVEMENT;

/* ---------------------------------------------------------------------- */
/* Drop table "EMPLOYEE"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE EMPLOYEE DROP CONSTRAINT PK_EMPLOYEE;

ALTER TABLE EMPLOYEE DROP CONSTRAINT UNQ_EMPLOYEE_1;

DROP TABLE EMPLOYEE;

/* ---------------------------------------------------------------------- */
/* Drop table "PRODUCT"                                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE PRODUCT DROP CONSTRAINT PK_PRODUCT;

ALTER TABLE PRODUCT DROP CONSTRAINT UNQ_PRODUCT_1;

DROP TABLE PRODUCT;

/* ---------------------------------------------------------------------- */
/* Drop table "DEPARTMENT"                                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE DEPARTMENT DROP CONSTRAINT PK_DEPARTMENT;

ALTER TABLE DEPARTMENT DROP CONSTRAINT UNQ_DEPARTMENT_1;

DROP TABLE DEPARTMENT;

/* ---------------------------------------------------------------------- */
/* Drop table "MOVEMENT_TYPE"                                             */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE MOVEMENT_TYPE DROP CONSTRAINT PK_MOVEMENT_TYPE;

ALTER TABLE MOVEMENT_TYPE DROP CONSTRAINT UNQ_MOVEMENT_TYPE_1;

DROP TABLE MOVEMENT_TYPE;

/* ---------------------------------------------------------------------- */
/* Drop table "LOCATION"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE LOCATION DROP CONSTRAINT PK_LOCATION;

ALTER TABLE LOCATION DROP CONSTRAINT UNQ_LOCATION_1;

DROP TABLE LOCATION;

/* ---------------------------------------------------------------------- */
/* Drop table "PRODUCT_CATEGORY"                                          */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE PRODUCT_CATEGORY DROP CONSTRAINT PK_PRODUCT_CATEGORY;

ALTER TABLE PRODUCT_CATEGORY DROP CONSTRAINT UNQ_PRODUCT_CATEGORY_1;

DROP TABLE PRODUCT_CATEGORY;

/* ---------------------------------------------------------------------- */
/* Drop domains                                                           */
/* ---------------------------------------------------------------------- */

DROP DOMAIN DOM_TXN_TYPE;

/* ---------------------------------------------------------------------- */
/* Drop sequences                                                         */
/* ---------------------------------------------------------------------- */

DELETE FROM RDB$GENERATORS WHERE RDB$GENERATOR_NAME = 'GEN_HILO';
