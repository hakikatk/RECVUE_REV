 /*==========================================================================+
 |            Recvue Inc. Palo Alto , CA                                     |
 +===========================================================================+
 |                                                                           |
 |  File Name:      ORDER_REVENUE_DETAILS_ALL.sql                            |
 |  Object Name:    ORDER_REVENUE_DETAILS_ALL                                |
 |  Description:    Revenue Engine Table                                     |
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
drop TABLE ADORB.ORDER_REVENUE_DETAILS_ALL ;

 CREATE TABLE ADORB.ORDER_REVENUE_DETAILS_ALL 
   (	REV_SCH_ID NUMBER NOT NULL ENABLE, 
        REV_ALLOCATION_ID NUMBER NOT NULL,
	ORDER_ID NUMBER, 
	LINE_ID NUMBER, 
	REC_REC_TYPE VARCHAR2(30), 
	REVENUE_TYPE VARCHAR2(30), 
	REVENUE_FROM_DATE DATE, 
	REVENUE_TO_DATE DATE, 
	REVENUE_FROM_PERIOD VARCHAR2(25 BYTE), 
	REVENUE_TO_PERIOD VARCHAR2(25 BYTE), 
	CUSTOMER_TRX_LINE_ID NUMBER, 
	REVENUE_ACCOUNT VARCHAR2(240 BYTE), 
	LEDGER VARCHAR2(25 BYTE), 
	LAST_UPDATE_DATE DATE, 
	LAST_UPDATED_BY NUMBER(15,0), 
	CREATION_DATE DATE, 
	CREATED_BY NUMBER(15,0), 
	PERCENT NUMBER, 
	AMOUNT NUMBER, 
	QUANTITY NUMBER, 
	UNIT_PRICE NUMBER,
	ADJUSTMENT NUMBER,
	GL_DATE DATE, 
	GL_POSTED_DATE DATE, 
	CUST_TRX_LINE_SALESREP VARCHAR2(150 BYTE), 
	COMMENTS VARCHAR2(240 BYTE), 
	ATTRIBUTE_CATEGORY VARCHAR2(30 BYTE), 
	ATTRIBUTE1 VARCHAR2(150 BYTE), 
	ATTRIBUTE2 VARCHAR2(150 BYTE), 
	ATTRIBUTE3 VARCHAR2(150 BYTE), 
	ATTRIBUTE4 VARCHAR2(150 BYTE), 
	ATTRIBUTE5 VARCHAR2(150 BYTE), 
	ATTRIBUTE6 VARCHAR2(150 BYTE), 
	ATTRIBUTE7 VARCHAR2(150 BYTE), 
	ATTRIBUTE8 VARCHAR2(150 BYTE), 
	ATTRIBUTE9 VARCHAR2(150 BYTE), 
	ATTRIBUTE10 VARCHAR2(150 BYTE), 
	ORIGINAL_GL_DATE DATE, 
	ACCOUNT_CLASS VARCHAR2(20 BYTE), 
	CUSTOMER_TRX_ID NUMBER(15,0), 
	ACCTD_AMOUNT NUMBER, 
	ATTRIBUTE11 VARCHAR2(150 BYTE), 
	ATTRIBUTE12 VARCHAR2(150 BYTE), 
	ATTRIBUTE13 VARCHAR2(150 BYTE), 
	ATTRIBUTE14 VARCHAR2(150 BYTE), 
	ATTRIBUTE15 VARCHAR2(150 BYTE), 
	LATEST_REC_FLAG VARCHAR2(1 BYTE), 
	ORG_ID NUMBER(15,0), 
	REVENUE_ADJUSTMENT_ID NUMBER(15,0), 
	REC_OFFSET_FLAG VARCHAR2(1 BYTE), 
	EVENT_ID NUMBER(15,0), 
	USER_GENERATED_FLAG VARCHAR2(1 BYTE), 
	TENANT_ID NUMBER, 
	LEGACY_FROM_DATE DATE, 
	LEGACY_TO_DATE DATE, 
	CREDIT_RMA_FLAG VARCHAR2(1 BYTE), 
	CASH_BASIS_FLAG VARCHAR2(1 BYTE), 
	EOC_FLAG VARCHAR2(1 BYTE), 
	REV_CHANNEL VARCHAR2(150 BYTE), 
	RECOGNIZED_REV NUMBER, 
	UNRECOGNIZED_REV NUMBER, 
	ACTUAL_REV_EFFECTIVE NUMBER, 
	CALENDAR_YEAR NUMBER(4,0), 
	CALENDAR_MONTH NUMBER(2,0), 
	CALENDAR_QUARTER NUMBER(1,0), 
	STATUS VARCHAR2(30 BYTE), 
	LINE_TYPE VARCHAR2(30 BYTE), 
	TRACKING_OPTIONS VARCHAR2(30 BYTE), 
	BILLING_CHANNEL VARCHAR2(30 BYTE), 
	LINE_NUMBER NUMBER, 
	ORDER_NUMBER VARCHAR2(60 BYTE), 
	BONUS_FLAG VARCHAR2(3 BYTE), 
	ADJUST_AMOUNT NUMBER, 
	FISCAL_MONTH NUMBER, 
	FISCAL_QUARTER NUMBER, 
	FISCAL_YEAR NUMBER, 
	PERIOD_MONTH VARCHAR2(10 BYTE), 
	REVENUE_EVENT VARCHAR2(50 BYTE), 
	REVENUE_SCHEDULE VARCHAR2(50 BYTE), 
	SCHEDULE_GEN_DATE  DATE,
	 CONSTRAINT ORDER_REVENUE_DETAILS_ALL_PK PRIMARY KEY (REV_SCH_ID),
	 CONSTRAINT ORDER_REVENUE_DETAILS_ALL_FK FOREIGN KEY (REV_ALLOCATION_ID) REFERENCES ADORB.ORDER_REV_ALLOCATIONS_ALL(REV_ALLOCATION_ID)
)
TABLESPACE USERS ;
