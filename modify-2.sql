/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Alter database script                           */
/* Created on:            2021-03-07 20:27                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE EMPLOYEE DROP CONSTRAINT DEPARTMENT_EMPLOYEE;

ALTER TABLE MOVEMENT DROP CONSTRAINT DEPARTMENT_MOVEMENT;

/* ---------------------------------------------------------------------- */
/* Alter table "DEPARTMENT"                                               */
/* ---------------------------------------------------------------------- */

ALTER TABLE DEPARTMENT ADD
    IS_SYSTEM INTEGER;

/* ---------------------------------------------------------------------- */
/* Add foreign key constraints                                            */
/* ---------------------------------------------------------------------- */

ALTER TABLE EMPLOYEE ADD CONSTRAINT DEPARTMENT_EMPLOYEE 
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID);

ALTER TABLE MOVEMENT ADD CONSTRAINT DEPARTMENT_MOVEMENT 
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (DEPARTMENT_ID);
