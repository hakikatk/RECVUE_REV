 /*==========================================================================+
 |            Recvue Inc. Palo Alto , CA                                     |
 +===========================================================================+
 |                                                                           |
 |  File Name:      ORDER_REV_ALLOCATIONS_ALL                                |
 |  Object Name:    ORDER_REV_ALLOCATIONS_ALL                                |
 |  Description:    Revenue Allocation Table                                 |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | Revision History:                                                         |
 |                                                                           |
 |  VERSION  DATE         AUTHOR            DESCRIPTION                      |
 | -------  --------     --------------    --------------------------------- |
 | Draft1A  12-23-2017     HK             Initial version                    |
 +===========================================================================*/

 CREATE  TABLE ADORB.ORDER_REV_ALLOCATIONS_ALL 
   (	REV_ALLOCATION_ID NUMBER NOT NULL ENABLE, 
	ORDER_ID NUMBER, 
	LINE_ID NUMBER, 
	ITEM_ID NUMBER,
	REV_REC_TYPE VARCHAR2(30), 
	REVENUE_TYPE VARCHAR2(30), 
	REVENUE_FROM_DATE DATE, 
	REVENUE_TO_DATE DATE, 
	NO_OF_MONTHS NUMBER,
	QUANTITY NUMBER,
	UNIT_PRICE NUMBER,
	TOTAL_AMOUNT NUMBER,
	ACCOUNTING_RULE VARCHAR2(30),
	LAST_UPDATE_DATE DATE,
	LAST_UPDATED_BY  NUMBER,
	CREATION_DATE    DATE,
        CREATED_BY       NUMBER,
	ATTRIBUTE_CATEGORY VARCHAR2(30), 
	ATTRIBUTE1 VARCHAR2(150), 
	ATTRIBUTE2 VARCHAR2(150), 
	ATTRIBUTE3 VARCHAR2(150), 
	ATTRIBUTE4 VARCHAR2(150), 
	ATTRIBUTE5 VARCHAR2(150), 
	ATTRIBUTE6 VARCHAR2(150), 
	ATTRIBUTE7 VARCHAR2(150), 
	ATTRIBUTE8 VARCHAR2(150), 
	ATTRIBUTE9 VARCHAR2(150), 
	ATTRIBUTE10 VARCHAR2(150), 
	ATTRIBUTE11 VARCHAR2(150), 
	ATTRIBUTE12 VARCHAR2(150), 
	ATTRIBUTE13 VARCHAR2(150), 
	ATTRIBUTE14 VARCHAR2(150), 
	ATTRIBUTE15 VARCHAR2(150),
	ORG_ID      NUMBER,
	TENANT_ID   NUMBER,
	REQUEST_ID  NUMBER,
	 CONSTRAINT ORDER_REV_ALLOCATIONS_ALL_PK PRIMARY KEY (REV_ALLOCATION_ID)
 )
  TABLESPACE USERS ;
  
  ALTER TABLE ADORB.ORDER_REV_ALLOCATIONS_ALL	ADD (ORG_ID      NUMBER,
	TENANT_ID   NUMBER);
  
  