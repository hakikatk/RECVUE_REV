/*==========================================================================+
|            Recvue Inc. Palo Alto , CA                                     |
+===========================================================================+
|                                                                           |
|  File Name:      GEN_REV_SCH_PKG.pkb                                      |
|  Object Name:    GEN_REV_SCH_PKG                                          |
|  Description:    Package Spec for Recvue Revenue Engine                   |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
|                                                                           |
| Revision History:                                                         |
|                                                                           |
|  VERSION  DATE         AUTHOR            DESCRIPTION                      |
| -------  --------     --------------    --------------------------------- |
| Draft1A  12-23-2017    Hakikat          initial version                   |
+===========================================================================*/

CREATE OR REPLACE PACKAGE BODY GEN_REV_SCH_PKG AS

g_request_id NUMBER;

g_log_level  NUMBER := 1;
g_write_log  VARCHAR2(1) := 'Y';
  
  -- ************************************************************
  -- Procedure Name: GET_CALENDAR_DETAILS
  -- Purpose       : Procedure to get GL Period details for given
  --                 Date and Tenant 
  --
  -- Parameters    :
  --    Name                 Type
  --    -------------------- --------------------------
  --    pi_request_id        IN NUMBER
  --    pi_tenant_id         IN NUMBER
  --    pi_org_id            IN NUMBER
  --    pi_order_id          IN NUMBER
  -- ************************************************************
  PROCEDURE GET_CALENDAR_DETAILS(pi_date            IN  DATE,
                                 pi_tenant_id       IN  NUMBER,
                                 po_start_date      OUT DATE,
                                 po_end_Date        OUT DATE,
                                 po_period_name     OUT VARCHAR2,
                                 po_period_num      OUT NUMBER,
                                 po_period_qtr      OUT NUMBER,
                                 po_period_year     OUT NUMBER,
                                 po_period_set_name OUT VARCHAR
                                )
  AS
  l_period_set_name   GL_PERIOD_STATUSES.period_set_name%TYPE := NULL;
  l_period_start_date GL_PERIOD_STATUSES.start_date%TYPE      := NULL;
  l_period_end_date   GL_PERIOD_STATUSES.end_date%TYPE        := NULL;
  l_period_name       GL_PERIOD_STATUSES.period_name%TYPE     := NULL;
  l_period_year       GL_PERIOD_STATUSES.period_year%TYPE     := NULL;
  l_period_num        GL_PERIOD_STATUSES.period_num%TYPE      := NULL;
  l_period_qtr        GL_PERIOD_STATUSES.quarter_num%TYPE     := NULL;
  BEGIN
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : *** Start ***', g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Parameter (pi_date): '||pi_date, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Parameter (pi_tenant_id): '||pi_tenant_id, g_write_log, g_log_level);
  
     -- Get Calendar Period Set Name
     BEGIN
        l_period_set_name := NULL;
  
        SELECT attribute1
          INTO l_period_set_name
          FROM core_lookup_values
         WHERE 1 = 1
           AND tenant_id = pi_tenant_id
           AND lookup_type = 'CALENDAR_PERIOD_SET'
           AND attribute2  = 'CALENDAR'
           AND NVL(enabled_flag, 'N') = 'Y'
           AND TRUNC(pi_date) BETWEEN TRUNC(NVL(start_date_active, pi_date)) AND TRUNC(NVL(end_date_active, pi_date));
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_period_set_name := 'CAL_PERIOD_SET';
           UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Calendar Not defined, Settingup Period Set Name to CAL_PERIOD_SET', g_write_log, g_log_level);
        WHEN OTHERS THEN
           l_period_set_name := 'CAL_PERIOD_SET';
           UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Unknown exception while cheking for calendar in lookup: '||SQLERRM, g_write_log, g_log_level);
           UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Settingup Period Set Name to CAL_PERIOD_SET', g_write_log, g_log_level);
     END;
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : l_period_set_name: '||l_period_set_name, g_write_log, g_log_level);
  
     -- Get Calendar details for given Period Set Name and Given Date
     BEGIN
        l_period_start_date := NULL;
        l_period_end_date   := NULL;
        l_period_name       := NULL;
        l_period_year       := NULL;
        l_period_num        := NULL;
        l_period_qtr        := NULL;
  
        SELECT start_date,
               end_date,
               period_name,
               period_year,
               period_num,
               quarter_num
          INTO l_period_start_date,
               l_period_end_date,
               l_period_name,
               l_period_year,
               l_period_num,
               l_period_qtr
          FROM gl_period_statuses
         WHERE UPPER(period_set_name) = UPPER(l_period_set_name)
        -- AND UPPER(period_name) = UPPER(TO_CHAR(to_date(i.billing_period_from,'DD-MON-RR'),'MON-RR'))
           AND TRUNC(pi_date) BETWEEN start_date AND end_date
           AND tenant_id = pi_tenant_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_period_start_date := NULL;
            l_period_end_date   := NULL;
            l_period_name       := NULL;
            l_period_year       := NULL;
            l_period_num        := NULL;
            l_period_qtr        := NULL;
            UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : No Data Found in GL Period Statuses for given Period Set Name: '||UPPER(l_period_set_name)||' and Date: '||pi_date, g_write_log, g_log_level);
         WHEN OTHERS THEN
            l_period_start_date := NULL;
            l_period_end_date   := NULL;
            l_period_name       := NULL;
            l_period_year       := NULL;
            l_period_num        := NULL;
            l_period_qtr        := NULL;
            UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Unexpectd exception while fetching Period details from GL Period Statuses for given Period Set Name: '||UPPER(l_period_set_name)||' and Date: '||pi_date||' is:'||SQLERRM, g_write_log, g_log_level);
     END;
  
     po_start_date      := l_period_start_date;
     po_end_Date        := l_period_end_date;
     po_period_name     := l_period_name;
     po_period_num      := l_period_num;
     po_period_qtr      := l_period_qtr;
     po_period_year     := l_period_year;
     po_period_set_name := l_period_set_name;
  
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_start_date): '||po_start_date, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_end_Date): '||po_end_Date, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_period_name): '||po_period_name, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_period_num): '||po_period_num, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_period_qtr): '||po_period_qtr, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_period_year): '||po_period_year, g_write_log, g_log_level);
     UTILITY_PKG.write_log(g_request_id, '** REV_ENGINE_PKG.get_calendar_details : Return Value (po_period_set_name): '||po_period_set_name, g_write_log, g_log_level);
END GET_CALENDAR_DETAILS;
 
  
  -- ******************************************************************
  --    PROCEDURE NAME: CREATE_REV_ALLOCATION
  --    Purpose       : Insert Rev Allocations
  --    Parameters    :
  --                    Name                      Type Data Type
  --                    ------------------------- ---- ----------------
  --                    p_rev_allocations         IN OUT NOCOPY  PL/SQL Table Collection Type
  --                    pi_request_id             IN   NUMBER
  --                    pi_request_id             IN   NUMBER
  -- ******************************************************************
  PROCEDURE CREATE_REV_ALLOCATION(p_rev_allocations IN OUT NOCOPY ORDER_REV_ALLOCATIONS_ALL%ROWTYPE, pi_request_id IN NUMBER)
  AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
 
     INSERT INTO ORDER_REV_ALLOCATIONS_ALL
                   (REV_ALLOCATION_ID ,
		    ORDER_ID  ,
		    LINE_ID ,
		    ITEM_ID ,
		    REV_REC_TYPE ,
		    REVENUE_TYPE ,
		    REVENUE_FROM_DATE ,
		    REVENUE_TO_DATE ,
		    NO_OF_MONTHS ,
		    QUANTITY ,
		    UNIT_PRICE ,
		    TOTAL_AMOUNT ,
		    ACCOUNTING_RULE ,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY ,
		    CREATION_DATE   ,
                    CREATED_BY   ,
		    ATTRIBUTE_CATEGORY , 
		    ATTRIBUTE1 , 
		    ATTRIBUTE2 , 
		    ATTRIBUTE3 , 
		    ATTRIBUTE4 , 
		    ATTRIBUTE5 , 
		    ATTRIBUTE6 , 
		    ATTRIBUTE7 , 
		    ATTRIBUTE8 , 
		    ATTRIBUTE9 , 
		    ATTRIBUTE10 , 
		    ATTRIBUTE11 , 
		    ATTRIBUTE12 , 
		    ATTRIBUTE13 , 
		    ATTRIBUTE14 , 
		    ATTRIBUTE15 ,
            TENANT_ID,
            ORG_ID,
		    REQUEST_ID
                    )
     VALUES 
                    (p_rev_allocations.rev_allocation_id
                    ,p_rev_allocations.order_id
                    ,p_rev_allocations.line_id
                    ,p_rev_allocations.item_id
                    ,p_rev_allocations.rev_rec_type
                    ,p_rev_allocations.revenue_type
                    ,p_rev_allocations.revenue_from_date
                    ,p_rev_allocations.revenue_to_date
                    ,p_rev_allocations.no_of_months
                    ,p_rev_allocations.quantity 
                    ,p_rev_allocations.unit_price 
		    ,p_rev_allocations.total_amount 
		    ,p_rev_allocations.accounting_rule 
                    ,p_rev_allocations.last_update_date
                    ,p_rev_allocations.last_updated_by
                    ,p_rev_allocations.creation_date
                    ,p_rev_allocations.created_by
		    ,p_rev_allocations.ATTRIBUTE_CATEGORY 
		    ,p_rev_allocations.ATTRIBUTE1 
		    ,p_rev_allocations.ATTRIBUTE2 
		    ,p_rev_allocations.ATTRIBUTE3 
		    ,p_rev_allocations.ATTRIBUTE4 
		    ,p_rev_allocations.ATTRIBUTE5 
		    ,p_rev_allocations.ATTRIBUTE6 
		    ,p_rev_allocations.ATTRIBUTE7 
		    ,p_rev_allocations.ATTRIBUTE8 
		    ,p_rev_allocations.ATTRIBUTE9 
		    ,p_rev_allocations.ATTRIBUTE10
		    ,p_rev_allocations.ATTRIBUTE11
		    ,p_rev_allocations.ATTRIBUTE12
		    ,p_rev_allocations.ATTRIBUTE13
		    ,p_rev_allocations.ATTRIBUTE14
		    ,p_rev_allocations.ATTRIBUTE15  
            ,p_rev_allocations.tenant_id
            ,p_rev_allocations.org_id
		    ,pi_request_id
                    );
     COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.create_rev_allocation) : Unknown exception while inserting Revenue Allocaion details: '||SQLERRM, 'Y', 0);
  END CREATE_REV_ALLOCATION;
  
  -- ******************************************************************
  --    PROCEDURE NAME: INSERT_REVENUE_DETAILS
  --    Purpose       : Insert Revenue Details
  --    Parameters    :
  --                    Name                      Type Data Type
  --                    ------------------------- ---- ----------------
  --                    p_revenue_details         IN OUT NOCOPY  order_revenue_details_all%ROWTYPE
  --                    pi_request_id             IN   NUMBER
  --                    pi_request_id             IN   NUMBER
  -- ******************************************************************
  PROCEDURE INSERT_REVENUE_DETAILS(p_revenue_details IN t_revenue_schedules, pi_request_id IN NUMBER)
  AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  FORALL i in 1..p_revenue_details.count
     INSERT INTO order_revenue_details_all
                    (rev_sch_id
                    ,rev_allocation_id
                    ,order_id
                    ,line_id
                    ,revenue_type
                    ,revenue_from_date
                    ,revenue_to_date
                    ,revenue_from_period
                    ,revenue_to_period
                    ,customer_trx_line_id
                    ,revenue_account
                    ,ledger
                    ,last_update_date
                    ,last_updated_by
                    ,creation_date
                    ,created_by
                    ,percent
                    ,amount
                    ,quantity
                    ,unit_price
                    ,adjustment
                    ,gl_date
                    ,gl_posted_date
                    ,cust_trx_line_salesrep
                    ,comments
                    ,attribute_category
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,original_gl_date
                    ,account_class
                    ,customer_trx_id
                    ,acctd_amount
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,latest_rec_flag
                    ,org_id
                    ,revenue_adjustment_id
                    ,rec_offset_flag
                    ,event_id
                    ,user_generated_flag
                    ,tenant_id
                    ,legacy_from_date
                    ,legacy_to_date
                    ,credit_rma_flag
                    ,cash_basis_flag
                    ,eoc_flag
                    ,rev_channel
                    ,recognized_rev
                    ,unrecognized_rev
                    ,actual_rev_effective
                    ,calendar_year
                    ,calendar_month
                    ,calendar_quarter
                    ,status
                    ,line_type
                    ,tracking_options
                    ,billing_channel
                    ,order_number
                    ,line_number
                    ,bonus_flag
                    ,fiscal_month
                    ,fiscal_quarter
                    ,fiscal_year
                    ,period_month
                    ,revenue_event
                    ,revenue_schedule
                    ,schedule_gen_date
                    )
     VALUES 
                    (p_revenue_details(i).rev_sch_id
                    ,p_revenue_details(i).rev_allocation_id
                    ,p_revenue_details(i).order_id
                    ,p_revenue_details(i).line_id
                    ,p_revenue_details(i).revenue_type
                    ,p_revenue_details(i).revenue_from_date
                    ,p_revenue_details(i).revenue_to_date
                    ,p_revenue_details(i).revenue_from_period
                    ,p_revenue_details(i).revenue_to_period
                    ,p_revenue_details(i).customer_trx_line_id
                    ,p_revenue_details(i).revenue_account
                    ,p_revenue_details(i).ledger
                    ,p_revenue_details(i).last_update_date
                    ,p_revenue_details(i).last_updated_by
                    ,p_revenue_details(i).creation_date
                    ,p_revenue_details(i).created_by
                    ,p_revenue_details(i).percent
                    ,p_revenue_details(i).amount
                    ,p_revenue_details(i).quantity
                    ,p_revenue_details(i).unit_price
                    ,p_revenue_details(i).adjustment
                    ,p_revenue_details(i).gl_date
                    ,p_revenue_details(i).gl_posted_date
                    ,p_revenue_details(i).cust_trx_line_salesrep
                    ,p_revenue_details(i).comments
                    ,p_revenue_details(i).attribute_category
                    ,p_revenue_details(i).attribute1
                    ,p_revenue_details(i).attribute2
                    ,p_revenue_details(i).attribute3
                    ,p_revenue_details(i).attribute4
                    ,p_revenue_details(i).attribute5
                    ,p_revenue_details(i).attribute6
                    ,p_revenue_details(i).attribute7
                    ,p_revenue_details(i).attribute8
                    ,p_revenue_details(i).attribute9
                    ,p_revenue_details(i).attribute10
                    ,p_revenue_details(i).original_gl_date
                    ,p_revenue_details(i).account_class
                    ,p_revenue_details(i).customer_trx_id
                    ,p_revenue_details(i).acctd_amount
                    ,p_revenue_details(i).attribute11
                    ,p_revenue_details(i).attribute12
                    ,p_revenue_details(i).attribute13
                    ,p_revenue_details(i).attribute14
                    ,p_revenue_details(i).attribute15
                    ,p_revenue_details(i).latest_rec_flag
                    ,p_revenue_details(i).org_id
                    ,p_revenue_details(i).revenue_adjustment_id
                    ,p_revenue_details(i).rec_offset_flag
                    ,p_revenue_details(i).event_id
                    ,p_revenue_details(i).user_generated_flag
                    ,p_revenue_details(i).tenant_id
                    ,p_revenue_details(i).legacy_from_date
                    ,p_revenue_details(i).legacy_to_date
                    ,p_revenue_details(i).credit_rma_flag
                    ,p_revenue_details(i).cash_basis_flag
                    ,p_revenue_details(i).eoc_flag
                    ,p_revenue_details(i).rev_channel
                    ,p_revenue_details(i).recognized_rev
                    ,p_revenue_details(i).unrecognized_rev
                    ,p_revenue_details(i).actual_rev_effective
                    ,p_revenue_details(i).calendar_year
                    ,p_revenue_details(i).calendar_month
                    ,p_revenue_details(i).calendar_quarter
                    ,p_revenue_details(i).status
                    ,p_revenue_details(i).line_type
                    ,p_revenue_details(i).tracking_options
                    ,p_revenue_details(i).billing_channel
                    ,p_revenue_details(i).order_number
                    ,p_revenue_details(i).line_number
                    ,p_revenue_details(i).bonus_flag
                    ,p_revenue_details(i).fiscal_month
                    ,p_revenue_details(i).fiscal_quarter
                    ,p_revenue_details(i).fiscal_year
                    ,p_revenue_details(i).period_month
                    ,p_revenue_details(i).revenue_event
                    ,p_revenue_details(i).revenue_schedule
                    ,p_revenue_details(i).schedule_gen_date
                    );
     COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (REV_ENGINE_PKG.insert_revenue_details) : Unknown exception while inserting Revenue details: '||SQLERRM, 'Y', 0);
END INSERT_REVENUE_DETAILS;

PROCEDURE INSERT_REV_REC_DETAILS(p_rev_rec IN t_rev_rec, pi_request_id IN NUMBER)
AS
PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  FORALL i in 1..p_rev_rec.count
     INSERT INTO ORDER_REV_REC_DETAILS_ALL 
                    (rev_rec_id
                    ,rev_sch_id
                    ,order_id
                    ,line_id
                    ,revenue_type
                    ,revenue_from_date
                    ,revenue_to_date
                    ,revenue_from_period
                    ,revenue_to_period
                    ,customer_trx_line_id
                    ,revenue_account
                    ,ledger
                    ,last_update_date
                    ,last_updated_by
                    ,creation_date
                    ,created_by
                    ,percent
                    ,amount
                    ,quantity
                    ,unit_price
                    ,adjustment
                    ,gl_date
                    ,gl_posted_date
                    ,cust_trx_line_salesrep
                    ,comments
                    ,attribute_category
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,original_gl_date
                    ,account_class
                    ,customer_trx_id
                    ,acctd_amount
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,latest_rec_flag
                    ,org_id
                    ,revenue_adjustment_id
                    ,rec_offset_flag
                    ,event_id
                    ,user_generated_flag
                    ,tenant_id
                    ,legacy_from_date
                    ,legacy_to_date
                    ,credit_rma_flag
                    ,cash_basis_flag
                    ,eoc_flag
                    ,rev_channel
                    ,recognized_rev
                    ,unrecognized_rev
                    ,actual_rev_effective
                    ,calendar_year
                    ,calendar_month
                    ,calendar_quarter
                    ,status
                    ,line_type
                    ,tracking_options
                    ,billing_channel
                    ,order_number
                    ,line_number
                    ,bonus_flag
                    ,fiscal_month
                    ,fiscal_quarter
                    ,fiscal_year
                    ,period_month
                    ,revenue_event
                    ,revenue_schedule
                    )
     VALUES 
                    (p_rev_rec(i).rev_rec_id
                    ,p_rev_rec(i).rev_sch_id
                    ,p_rev_rec(i).order_id
                    ,p_rev_rec(i).line_id
                    ,p_rev_rec(i).revenue_type
                    ,p_rev_rec(i).revenue_from_date
                    ,p_rev_rec(i).revenue_to_date
                    ,p_rev_rec(i).revenue_from_period
                    ,p_rev_rec(i).revenue_to_period
                    ,p_rev_rec(i).customer_trx_line_id
                    ,p_rev_rec(i).revenue_account
                    ,p_rev_rec(i).ledger
                    ,p_rev_rec(i).last_update_date
                    ,p_rev_rec(i).last_updated_by
                    ,p_rev_rec(i).creation_date
                    ,p_rev_rec(i).created_by
                    ,p_rev_rec(i).percent
                    ,p_rev_rec(i).amount
                    ,p_rev_rec(i).quantity
                    ,p_rev_rec(i).unit_price
                    ,p_rev_rec(i).adjustment
                    ,p_rev_rec(i).gl_date
                    ,p_rev_rec(i).gl_posted_date
                    ,p_rev_rec(i).cust_trx_line_salesrep
                    ,p_rev_rec(i).comments
                    ,p_rev_rec(i).attribute_category
                    ,p_rev_rec(i).attribute1
                    ,p_rev_rec(i).attribute2
                    ,p_rev_rec(i).attribute3
                    ,p_rev_rec(i).attribute4
                    ,p_rev_rec(i).attribute5
                    ,p_rev_rec(i).attribute6
                    ,p_rev_rec(i).attribute7
                    ,p_rev_rec(i).attribute8
                    ,p_rev_rec(i).attribute9
                    ,p_rev_rec(i).attribute10
                    ,p_rev_rec(i).original_gl_date
                    ,p_rev_rec(i).account_class
                    ,p_rev_rec(i).customer_trx_id
                    ,p_rev_rec(i).acctd_amount
                    ,p_rev_rec(i).attribute11
                    ,p_rev_rec(i).attribute12
                    ,p_rev_rec(i).attribute13
                    ,p_rev_rec(i).attribute14
                    ,p_rev_rec(i).attribute15
                    ,p_rev_rec(i).latest_rec_flag
                    ,p_rev_rec(i).org_id
                    ,p_rev_rec(i).revenue_adjustment_id
                    ,p_rev_rec(i).rec_offset_flag
                    ,p_rev_rec(i).event_id
                    ,p_rev_rec(i).user_generated_flag
                    ,p_rev_rec(i).tenant_id
                    ,p_rev_rec(i).legacy_from_date
                    ,p_rev_rec(i).legacy_to_date
                    ,p_rev_rec(i).credit_rma_flag
                    ,p_rev_rec(i).cash_basis_flag
                    ,p_rev_rec(i).eoc_flag
                    ,p_rev_rec(i).rev_channel
                    ,p_rev_rec(i).recognized_rev
                    ,p_rev_rec(i).unrecognized_rev
                    ,p_rev_rec(i).actual_rev_effective
                    ,p_rev_rec(i).calendar_year
                    ,p_rev_rec(i).calendar_month
                    ,p_rev_rec(i).calendar_quarter
                    ,p_rev_rec(i).status
                    ,p_rev_rec(i).line_type
                    ,p_rev_rec(i).tracking_options
                    ,p_rev_rec(i).billing_channel
                    ,p_rev_rec(i).order_number
                    ,p_rev_rec(i).line_number
                    ,p_rev_rec(i).bonus_flag
                    ,p_rev_rec(i).fiscal_month
                    ,p_rev_rec(i).fiscal_quarter
                    ,p_rev_rec(i).fiscal_year
                    ,p_rev_rec(i).period_month
                    ,p_rev_rec(i).revenue_event
                    ,p_rev_rec(i).revenue_schedule
                    );
     COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (REV_ENGINE_PKG.insert_rev_rec_details) : Unknown exception while inserting Revenue details: '||SQLERRM, 'Y', 0);


END INSERT_REV_REC_DETAILS;

  PROCEDURE CALC_REV_AMOUNT_P(     pi_request_id IN NUMBER,
                                   pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER,
			           pi_line_type  IN VARCHAR2,
			           pi_unit_price IN NUMBER,
			           pi_quantity   IN NUMBER,
			           pi_uom        IN VARCHAR2,
			           pi_rev_rec_type IN VARCHAR2,
			           pi_period_start_date IN DATE,
			           pi_period_end_date   IN DATE,
			           po_rev_amount OUT NUMBER,
			           po_unit_price OUT NUMBER,
			           po_adjustment OUT NUMBER,
			           po_quantity   OUT NUMBER)
IS

l_adj_unit_price NUMBER :=0;
l_period_rev_amt NUMBER :=0;

l_period_first_day DATE;
l_period_last_day  DATE;

l_period_name VARCHAR2(30);
l_period_num  NUMBER;
l_period_qtr  NUMBER;
l_period_year NUMBER;
l_period_set  VARCHAR2(100);

l_period_rev_days   NUMBER;
l_total_no_of_days  NUMBER;
l_period_rev_amount NUMBER;

CURSOR c_amendments (pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER) IS
  SELECT d.PRF_DB_NAME column_name, d.old_value, d.new_value , d.effective_date
  from ORDER_CHANGE_REQUESTS h, 
       CR_DETAILS d 
 where h.cr_header_id     = d.cr_header_id
   AND NVL(h.org_id,-1)   = NVL2(d.org_id,-1,h.org_id)
   AND h.tenant_id        = d.tenant_id
   AND d.status           = 'PROCESSED'
   AND PRF_ENTITY_NAME    = 'ORDER_LINES_ALL'
   AND prf_entity_pk_field= 'LINE_ID'
   AND prf_entity_pk      = pi_line_id
   AND h.order_header_id  = pi_order_id
   AND h.org_id           = NVL(pi_org_id, h.org_id)
   AND h.tenant_id        = pi_tenant_id;
   
   l_adjustment            NUMBER;
   l_amend_price           NUMBER;
   l_old_price             NUMBER;
   l_prc_change_date       DATE;
   l_qty_change_date       DATE;
   l_amend_qty             NUMBER;
   l_old_qty               NUMBER;
   l_sch_price             NUMBER;
   l_line_qty              NUMBER;

BEGIN

 --Check for Price Adjustment
    UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P) : *** Start ***', 'Y', 0);
 
    UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P) : Parameters... '
                                        ||'pi_request_id: '||pi_request_id
                                        ||'pi_order_id: '||pi_order_id
                                        ||'pi_line_id: '||pi_line_id
                                        ||'pi_org_id: '||pi_org_id
                                        ||'pi_tenant_id: '||pi_tenant_id
                                        ||'pi_line_type: '||pi_line_type
                                        ||'pi_unit_price: '||pi_unit_price
                                        ||'pi_quantity: '||pi_quantity
                                        ||'pi_uom: '||pi_uom
                                        ||'pi_period_start_date: '||pi_period_start_date
                                        ||'pi_period_end_date: '||pi_period_end_date
                                        ||'pi_rev_rec_type: '||pi_rev_rec_type
                         ,'Y', 0
                        );
 
   l_qty_change_date :=null;
    l_prc_change_date :=null;
    l_amend_price :=null;
FOR i in c_amendments( pi_order_id ,
			           pi_line_id  ,
			           pi_org_id   ,
			           pi_tenant_id)
LOOP

  IF i.column_name= 'ORDERED_QUANTITY'  THEN
  
    IF pi_period_start_date>=i.effective_date and l_qty_change_date IS NULL 
    THEN
      l_amend_qty := i.new_value;
      l_qty_change_date :=i.effective_date;
      l_old_qty := i.old_value;
    ELSIF pi_period_start_date<=i.effective_date and l_qty_change_date IS NULL THEN
        l_amend_qty := i.old_value;
        l_qty_change_date :=i.effective_date;
        l_old_qty := i.old_value;
    ELSIF pi_period_start_date>=i.effective_date and l_qty_change_date<=i.effective_date THEN
        l_amend_qty := i.new_value;
        l_qty_change_date :=i.effective_date;
        l_old_qty := i.old_value;
    END IF;
   insert into test_log_messages (request_id, log_msg, creation_date, msg_id,log_level)
values (1111,'amend  qty and old qty'||l_amend_qty||' '||l_old_qty,sysdate, 1,1);   
    
  END IF;

  IF i.column_name like '%UNIT_PRICE%'  THEN
  
    IF pi_period_start_date>=i.effective_date and l_prc_change_date IS NULL  -->= and i.effective_date<=pi_period_end_date 
    THEN
      l_amend_price := i.new_value;
      l_prc_change_date :=i.effective_date;
      l_old_price := i.old_value;
    ELSIF pi_period_start_date<=i.effective_date and l_prc_change_date IS NULL  THEN
       l_old_price := i.old_value;
       l_prc_change_date :=i.effective_date;
       l_old_price := i.old_value;
    ELSIF pi_period_start_date>=i.effective_date and  l_prc_change_date<i.effective_date  THEN
        l_amend_price := i.new_value;
        l_prc_change_date :=i.effective_date; 
        l_old_price := i.old_value;
    END IF;
      
    
  END IF;
END LOOP;

 
 
 
 BEGIN
    SELECT adjusted_unit_price
      INTO l_sch_price
     FROM pricing_schedules_all
    WHERE order_id = pi_order_id
      AND line_id = pi_line_id
      AND org_id = pi_org_id
      AND tenant_id = pi_tenant_id
      AND pi_period_start_date BETWEEN pricing_from_date and pricing_to_date
      AND pi_period_end_date BETWEEN pricing_from_date and pricing_to_date;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_sch_price := pi_unit_price;
     WHEN OTHERS THEN
       l_sch_price := pi_unit_price;
        UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P- When Others Exception -Adjusted unit price )'||SQLERRM, 'Y', 0);
 END;
 

  UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P- Calculate Revenue Amount )', 'Y', 0);
IF l_amend_price IS NOT NULL THEN 
    l_adj_unit_price :=l_amend_price+(l_sch_price-l_amend_price);
ELSE
  l_adj_unit_price :=l_sch_price;
END IF;

 insert into test_log_messages (request_id, log_msg, creation_date, msg_id,log_level)
values (1111,'price'||l_adj_unit_price,sysdate, 1,1); 

UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P- Calculate Revenue Amount ) Adjusted Unit Price is'||l_adj_unit_price, 'Y', 0);


IF l_amend_qty IS NULL THEN
  l_line_qty:= pi_quantity;
ELSE
  l_line_qty := l_amend_qty;
END IF;  

 insert into test_log_messages (request_id, log_msg, creation_date, msg_id,log_level)
values (1111,' l_line_qty'|| l_line_qty,sysdate, 1,1); 

UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P- Calculate Revenue Amount ) Quantity is'||l_line_qty, 'Y', 0);


 --calc Amount 
 IF pi_line_type = 'P_COMMIT' AND UPPER(pi_rev_rec_type) = 'MONTHLY' THEN
    IF NVL(pi_uom,'MON') = 'MON'  THEN
      l_period_rev_amount := l_adj_unit_price*l_line_qty;
    END IF;
 END IF;
 
   --calc partial month rev amt.
 --Get First Day and Last Day of period.
 --Get Calender Dates
 
             GET_CALENDAR_DETAILS(pi_date            =>pi_period_start_date,
                                  pi_tenant_id       =>pi_tenant_id,
                                  po_start_date      =>l_period_first_day,
                                  po_end_Date        =>l_period_last_day,
                                  po_period_name     =>l_period_name,
                                  po_period_num      =>l_period_num,
                                  po_period_qtr      =>l_period_qtr,
                                  po_period_year     =>l_period_year,
                                  po_period_set_name =>l_period_set
                                ) ;
 
 --l_period_first_day := add_months(last_day(pi_period_start_date),-1)+1;
 
 --l_period_last_day := LAST_DAY(pi_period_end_date);
 
 IF (trunc(l_period_first_day) <> trunc(pi_period_start_date)) -- OR (trunc(l_period_last_day)<>trunc(pi_period_end_date)))  
 THEN
   
   l_period_rev_days:= pi_period_end_date - pi_period_start_date+1;
   l_total_no_of_days := l_period_last_day-l_period_first_day+1;
   l_period_rev_amount := (((l_adj_unit_price*l_line_qty)*l_period_rev_days)/l_total_no_of_days);
 
 END IF;
 
l_adjustment := l_period_rev_amount - NVL(l_old_qty, l_line_qty)*NVL(l_old_price,l_adj_unit_price);
 
 po_rev_amount:=l_period_rev_amount;
 po_unit_price:=l_adj_unit_price;
 po_adjustment := l_adjustment;
 po_quantity   := l_line_qty;
 
  insert into test_log_messages (request_id, log_msg, creation_date, msg_id,log_level)
values (1111,'  po_rev_amount, po_unit_price,po_adjustment,po_quantity,pi_rev_rec_type,uom'|| po_rev_amount||', '||po_unit_price||','||','||po_adjustment||','||po_quantity||','||pi_rev_rec_type||pi_uom,sysdate, 1,1); 
 
 EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.CALC_REV_AMOUNT_P) : Unknown exception while inserting Revenue Allocaion details: '||SQLERRM, 'Y', 0);
END CALC_REV_AMOUNT_P;

  
  
  PROCEDURE GENERATE_REV_SCHEDULE (pi_request_id IN NUMBER,
			           pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER)
  IS
  
  CURSOR c_eligible_rev_lines (pi_order_id NUMBER,pi_line_id NUMBER,pi_org_id NUMBER,pi_tenant_id NUMBER)
  IS
    SELECT   oha.order_id,
                             oha.order_number,
                             oha.order_type,
                             oha.billing_batch,
                             oha.billing_cycle,
                             oha.billing_frequency,
                             oha.currency,
                             oha.invoicing_rule,
                             oha.salesrep,
                             ola.line_id,
                             ola.line_number,
                             ola.line_type,
                             ola.billing_trigger,
                             ola.effective_start_date,
                             ola.effective_end_date,
                             ola.accounting_rule,
                             ola.rev_start_date,
                             ola.rev_end_date,
                             ola.item_id,
                             ola.unit_price,
                             ola.ordered_quantity,
                             ola.uom,
                             ola.bonus_quantity,
                             ola.tracking_options,
                             ola.billing_channel_id,
                             oha.org_id,
                             ola.free_months,
                             ola.back_billing,
                             ola.free_eom,
                             ola.tenant_id,
                             ola.attribute1_d
                        FROM order_header_all oha,
                             order_lines_all ola
                       WHERE oha.order_id = ola.order_id
                       -- AND oha.status IN ('ACTIVE', 'DELIVERING','DRAFT')
                        --AND ola.status IN ('ACTIVE', 'DELIVERING','DRAFT')
                         AND NVL (ola.stop_billing, 'N') <> 'Y'
                         AND NVL (ola.billing_complete, 'N') <> 'Y'
                         AND oha.order_id = NVL(pi_order_id, oha.order_id)
                         AND ola.line_id = NVL(pi_line_id, ola.line_id)
                         AND NVL (oha.org_id, -1) =
                                DECODE (pi_org_id,
                                        NULL, NVL (oha.org_id, -1),
                                        pi_org_id
                                       )
                        AND oha.tenant_id  = NVL(pi_tenant_id,oha.tenant_id)               
                        AND NOT EXISTS (SELECT 'Y' FROM ORDER_REV_REC_DETAILS_ALL rev
                                         WHERE ola.order_id  = rev.order_id
                                           AND ola.line_id   = rev.line_id
                                           AND ola.org_id    = rev.org_id
                                           AND ola.tenant_id = rev.tenant_id
                                           AND rev.status    = 'RECOGNIZED')
                    ORDER BY oha.order_id,
                         ola.line_id
                    FOR UPDATE nowait     ;
  l_org_id           NUMBER;
  l_no_of_days       NUMBER;
  l_no_of_months     NUMBER;
  l_avg_daily_rev    NUMBER;
  l_avg_monthly_rev  NUMBER;
  l_act_monthly_rev  NUMBER;
  l_rev_recognized   NUMBER;
  l_rev_unrecognized NUMBER;
  l_actual_daily_rev NUMBER;
  l_del_qty          NUMBER;
  l_bonus_qty        NUMBER;
  l_avg_unit_price   NUMBER;
  l_ptd_rev          NUMBER;
  l_deferred         VARCHAR2(10);
  l_schedule         VARCHAR2(30);
  l_bonus            VARCHAR2(10);
  l_delivery_date_from DATE;
  l_delivery_date_to   DATE;
  l_ledger_name       VARCHAR2(60);
  l_sets_of_books_id  NUMBER;
  l_loop_count        NUMBER;
  l_err_flag          VARCHAR2(10);
  l_err_msg           VARCHAR2(2000);
  l_rev_alloc         VARCHAR2(10);
  l_revenue_details   t_revenue_schedules;
  l_rev_allocations   ORDER_REV_ALLOCATIONS_ALL%ROWTYPE;
  l_rec_alloc         NUMBER;
  l_rev_amount        NUMBER;
  l_start_date        DATE;
  l_period_start_date DATE;
  l_period_end_date   DATE;
    
  l_period_name VARCHAR2(30);
  l_period_num  NUMBER;
  l_period_qtr  NUMBER;
  l_period_year NUMBER;
  l_period_set  VARCHAR2(100);
  l_total_amount NUMBER;
  TYPE rev_sch_rec IS RECORD( order_id number, line_id number, org_id number, tenant_id number,
                       revenue_from_date date, revenue_to_date date,amount number,unit_price number);
  TYPE t_sch_rec IS TABLE OF rev_sch_rec INDEX BY binary_integer;   
  
  l_old_sch_rec t_sch_rec;
  
  l_adjustment NUMBER;
  l_unit_price NUMBER;
  l_quantity   NUMBER;
  l_bill_sch_exist NUMBER;
  l_sch_gen_date   DATE;
  l_chg_event_date DATE;
  l_rev_type       VARCHAR2(30);
  l_adjustment_case VARCHAR2(1);
  l_adjs_ln         VARCHAR2(1);
  

   BEGIN
  
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Start ***', 'Y', 0);
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.generate_rev_schedule) : Parameters... pi_request_id: '
                                            ||pi_request_id||' | '||'pi_tenant_id: '||pi_tenant_id||' | '||'pi_org_id: '||pi_org_id||' | '||'p_order_id: '||pi_order_id, 'Y', 0);

   g_request_id := pi_request_id;


     
   /* Get Ledger Name for given Ord Id  */
   BEGIN
      SELECT gsb.name
        INTO l_ledger_name
        FROM gl_sets_of_books gsb,
             hr_operating_units hou
       WHERE gsb.set_of_books_id = hou.set_of_books_id
         AND hou.organization_id = pi_org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_ledger_name := NULL;
   END;

   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (REV_ENGINE_PKG.calc_revenue_billed) : Ledger Name  '|| l_ledger_name, 'Y', 0);

     l_rec_alloc :=0;
     FOR r_rev IN c_eligible_rev_lines (pi_order_id,pi_line_id ,pi_org_id ,pi_tenant_id )
     LOOP
     
        --initialize variables
          l_no_of_days        :=0; 
          l_avg_daily_rev     :=0; 
          l_rev_recognized    :=0; 
          l_rev_unrecognized  :=0; 
          l_actual_daily_rev  :=0; 
          l_del_qty           :=0; 
          l_bonus_qty         :=0; 
          l_avg_unit_price    :=0; 
          l_ptd_rev           :=0; 
          
          l_no_of_months      :=0;
          l_avg_monthly_rev   :=0;
          l_act_monthly_rev   :=0;
          l_total_amount      :=0;
          l_quantity          := NULL;

          
	  l_deferred :=NULL;
	  l_schedule :=NULL;
	  l_bonus    :=NULL;
	  l_err_flag :=NULL;
	  l_err_msg  :=NULL;
	  l_rev_alloc :='N';
	  l_adjustment:= NULL;
	  l_unit_price :=NULL;
	  l_rec_alloc := l_rec_alloc+1;
	  l_rev_allocations :=NULL;
	  l_bill_sch_exist :=0;
	  l_rev_type := NULL;
	  l_adjustment_case :=NULL;
	  l_adjs_ln         := 'N';
 
    UTILITY_PKG.write_log(pi_request_id,'** Generate Revenue Schedule: (GEN_REV_SCH_PKG.generate_rev_schedule) :
                  c_eligible_rev_lines cursor : Order Id'||r_rev.order_id||' Line Id'||r_rev.line_id, 'Y', 0);

     UTILITY_PKG.write_log(pi_request_id,'** Generate Revenue Schedule: (GEN_REV_SCH_PKG.generate_rev_schedule) :
                 Check If Record Exists in Revenue Allocations', 'Y', 0); 
      BEGIN
         SELECT 'Y'
           INTO l_rev_alloc
           FROM order_rev_allocations_all
          WHERE order_id = r_rev.order_id
            AND line_id  = r_rev.line_id
            AND org_id   = r_rev.org_id
            AND tenant_id= r_rev.tenant_id;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_rev_alloc :='N';
      END;
  --
  
  --Check if adjustment line exist
        BEGIN
           SELECT 'Y'
             INTO l_adjs_ln
             FROM order_rev_allocations_all
            WHERE order_id = r_rev.order_id
              AND line_id  = r_rev.line_id
              AND org_id   = r_rev.org_id
              AND tenant_id= r_rev.tenant_id
              AND revenue_type = 'ADJUSTMENT';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_rev_alloc :='N';
      END;
   --------- 
   IF l_adjs_ln='Y' THEN
     
   
        BEGIN
           SELECT count(1), max(schedule_gen_date)
             INTO l_bill_sch_exist , l_sch_gen_date
             FROM order_revenue_details_all
            WHERE order_id = r_rev.order_id
              AND line_id  = r_rev.line_id
              AND org_id   = r_rev.org_id
              AND tenant_id= r_rev.tenant_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_bill_sch_exist :=0;
               l_sch_gen_date := NULL;
       END;
    ELSE
                 BEGIN
	            SELECT count(1), min(revenue_from_date)
	              INTO l_bill_sch_exist , l_sch_gen_date
	              FROM order_revenue_details_all
	             WHERE order_id = r_rev.order_id
	               AND line_id  = r_rev.line_id
	               AND org_id   = r_rev.org_id
	               AND tenant_id= r_rev.tenant_id;
	         EXCEPTION
	             WHEN NO_DATA_FOUND THEN
	                l_bill_sch_exist :=0;
	                l_sch_gen_date := NULL;
       END;
    END IF;
       
      BEGIN 
         SELECT max(d.effective_date)
           INTO l_chg_event_date
         from ORDER_CHANGE_REQUESTS h, 
              CR_DETAILS d 
        where h.cr_header_id     = d.cr_header_id
          AND NVL(h.org_id,-1)   = NVL2(d.org_id,-1,h.org_id)
          AND h.tenant_id        = d.tenant_id
          AND d.status           = 'PROCESSED'
          AND PRF_ENTITY_NAME    = 'ORDER_LINES_ALL'
          AND prf_entity_pk_field= 'LINE_ID'
          AND d.PRF_DB_NAME in ('ORDERED_QUANTITY','UNIT_PRICE','UOM_CONV_UNIT_PRICE')
          AND prf_entity_pk      = r_rev.line_id
          AND h.order_header_id  = r_rev.order_id
          AND h.org_id           = NVL(r_rev.org_id, h.org_id)
          AND h.tenant_id        = r_rev.tenant_id;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_chg_event_date := NULL;
     END;
  
      IF l_rev_alloc = 'Y' THEN
      
       UTILITY_PKG.write_log(pi_request_id,'** Generate Revenue Schedule: (GEN_REV_SCH_PKG.generate_rev_schedule) :
                 Delete Record From Revenue Allocations', 'Y', 0); 
        
        -- Insert existing records into pl/sql table to be used in case of price change in middleof contract
       /* 
        l_old_sch_rec.DELETE;
        
        SELECT order_id, line_id,org_id,tenant_id, revenue_start_date, revenue_end_date,amount , unit_price
           BULK COLLECT INTO l_old_sch_rec
         FROM ORDER_REVENUE_DETAILS_ALL
	WHERE order_id = r_rev.order_id
	  AND line_id  = r_rev.line_id
	  AND org_id   = r_rev.org_id
	  AND tenant_id= r_rev.tenant_id;   
        */

      IF l_bill_sch_exist > 0 AND NVL(l_sch_gen_date,sysdate) < NVL(l_chg_event_date,sysdate) 
      AND l_chg_event_date IS NOT NULL
      THEN
      
	 /*UPDATE ORDER_REVENUE_DETAILS_ALL
	    SET status = 'EXPIRED'
	  WHERE order_id = r_rev.order_id
	    AND line_id  = r_rev.line_id
	    AND org_id   = r_rev.org_id
            AND tenant_id= r_rev.tenant_id
            AND revenue_from_date >= l_chg_event_date; */
           l_adjustment_case:='Y';
      
      ELSE
           
           
           DELETE FROM ORDER_REVENUE_DETAILS_ALL
            WHERE order_id = r_rev.order_id
              AND line_id  = r_rev.line_id
              AND org_id   = r_rev.org_id
              AND tenant_id= r_rev.tenant_id;  
              
        DELETE FROM order_rev_allocations_all
            WHERE order_id = r_rev.order_id
              AND line_id  = r_rev.line_id
              AND org_id   = r_rev.org_id
              AND tenant_id= r_rev.tenant_id;
              
      END IF;        
      END IF;   
      
      COMMIT;
      
       BEGIN
       SELECT UPPER(rev_deferred), UPPER(rev_schedule), UPPER(rev_bonus)
                 INTO l_deferred, l_schedule, l_bonus
                 FROM ar_accounting_rules
                WHERE 1 = 1
                  AND UPPER(name) = UPPER(r_rev.accounting_rule)
                  AND tenant_id = pi_tenant_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_deferred := NULL;
                   l_schedule := NULL;
                   l_bonus    := NULL;
                   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_rev_schedule) : Accounting rule :'|| r_rev.accounting_rule||' not defined in lookup', 'Y', 0);
               WHEN OTHERS THEN
                   l_deferred := NULL;
                   l_schedule := NULL;
                   l_bonus    := NULL;
                   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_rev_schedule) : Unknown exception while fetching accounting rule details :'|| SQLERRM, 'Y', 0);
            END;

      
             UTILITY_PKG.write_log(pi_request_id,'** Generate Revenue Schedule: (GEN_REV_SCH_PKG.generate_rev_schedule) :
                 Create Revenue Allocation', 'Y', 0); 
            IF l_bill_sch_exist > 0 AND NVL(l_sch_gen_date,sysdate) < NVL(l_chg_event_date,sysdate) 
            AND l_chg_event_date IS NOT NULL
            THEN
                    l_rev_allocations.rev_allocation_id := REVALLOCSEQ.nextval;
                    l_rev_allocations.order_id          := r_rev.order_id;
                    l_rev_allocations.line_id           := r_rev.line_id;
                    l_rev_allocations.item_id           := r_rev.item_id;
                    l_rev_allocations.rev_rec_type      := l_schedule;
                    l_rev_allocations.revenue_type      := 'AMENDMENT';
                    l_rev_allocations.revenue_from_date := l_chg_event_date;
                    l_rev_allocations.revenue_to_date   := NVL(r_rev.rev_end_date,r_rev.effective_end_date);
                    l_rev_allocations.no_of_months      := ROUND(months_between(NVL(r_rev.rev_end_date, r_rev.effective_end_date), l_chg_event_date));
                    l_rev_allocations.quantity          := r_rev.ordered_quantity;
                    l_rev_allocations.unit_price        := r_rev.unit_price;
		   -- l_rev_allocations.total_amount      := round((r_rev.ordered_quantity*r_rev.unit_price),2);
		    l_rev_allocations.accounting_rule   := r_rev.accounting_rule;
                    l_rev_allocations.last_update_date  := sysdate;
                    l_rev_allocations.last_updated_by   := 1;
                    l_rev_allocations.creation_date     := sysdate;
                    l_rev_allocations.created_by        := 1;
		    l_rev_allocations.ATTRIBUTE_CATEGORY := NULL;
		    l_rev_allocations.ATTRIBUTE1         := NULL;
		    l_rev_allocations.ATTRIBUTE2 	      := NULL;
		    l_rev_allocations.ATTRIBUTE3 	      := NULL;
		    l_rev_allocations.ATTRIBUTE4 	      := NULL;
		    l_rev_allocations.ATTRIBUTE5 	      := NULL;
		    l_rev_allocations.ATTRIBUTE6 	      := NULL;
		    l_rev_allocations.ATTRIBUTE7 	      := NULL;
		    l_rev_allocations.ATTRIBUTE8 	      := NULL;
		    l_rev_allocations.ATTRIBUTE9 	      := NULL;
		    l_rev_allocations.ATTRIBUTE10	      := NULL;
		    l_rev_allocations.ATTRIBUTE11	      := NULL;
		    l_rev_allocations.ATTRIBUTE12	      := NULL;
		    l_rev_allocations.ATTRIBUTE13	      := NULL;
		    l_rev_allocations.ATTRIBUTE14	      := NULL;
		    l_rev_allocations.ATTRIBUTE15	      := NULL;  
                    l_rev_allocations.tenant_id               := r_rev.tenant_id;
                    l_rev_allocations.org_id                  := r_rev.org_id;
		    
		       IF l_schedule = 'MONTHLY' THEN
			   l_no_of_months := ROUND(months_between(NVL(r_rev.rev_end_date, r_rev.effective_end_date), l_chg_event_date));

			   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_rev_schedule) : Number of Months  '|| l_no_of_months, 'Y', 0);

			   IF l_no_of_months > 0 THEN
			      l_loop_count := l_no_of_months;
			   END IF;
		     END IF;     --  IF l_schedule = 'MONTHLY' THEN   
		     
		     ----
	  		     
		  l_revenue_details.DELETE;
		  FOR  r_sch IN 1..l_loop_count LOOP
		  
		                 IF l_schedule = 'MONTHLY' THEN
		                 
		                 
		                               l_start_date := ADD_MONTHS(l_chg_event_date,(r_sch-1));
		                              
		                              GET_CALENDAR_DETAILS(pi_date            =>l_start_date,
				                                   pi_tenant_id       =>pi_tenant_id,
				                                   po_start_date      =>l_period_start_date,
				                                   po_end_Date        =>l_period_end_date,
				                                   po_period_name     =>l_period_name,
				                                   po_period_num      =>l_period_num,
				                                   po_period_qtr      =>l_period_qtr,
				                                   po_period_year     =>l_period_year,
				                                   po_period_set_name =>l_period_set
                                                                  );
		
					  --check if start date is not first day of the month.
					  IF l_period_name = to_char(l_start_date, 'MON-RR') AND l_period_start_date <> l_start_date THEN
					     l_period_start_date :=l_start_date;
		                          END IF;
		        
		        		                          
		                          --check for last period
		                          IF l_period_name = to_char(NVL(r_rev.rev_end_date,r_rev.effective_end_date), 'MON-RR') THEN
		                             l_period_end_date :=NVL(r_rev.rev_end_date,r_rev.effective_end_date);
		                          END IF;
		                  
		         /*         -- Check if amount was changed in middle of contract
		                 IF r_rev.attribute1_d IS NOT NULL and l_period_start_date<r_rev.attribute1_d THEN 
		                  FOR k in l_old_sch_rec.COUNT LOOP
		                    IF l_period_start_date = k.revenue_from_date AND l_period_end_date =k.revenue_period_end_date
		                       AND r_rev.order_id = k.order_id and r_rev.line_id = k.line_id THEN
		                       
		                      l_rev_amount := k.amount;
		                      l_unit_price := l.unit_price;
		                    --  l_adjustment := r_rev.unit_price - k.unit_price;
		                  END IF;
		                  END LOOP;
		                  
		                  ELSIF r_rev.attribute1_d IS NOT NULL and l_period_start_date>=r_rev.attribute1_d THEN 
		                     FOR k in l_old_sch_rec.COUNT LOOP
				          IF l_period_start_date = k.revenue_from_date AND l_period_end_date =k.revenue_period_end_date
						AND r_rev.order_id = k.order_id and r_rev.line_id = k.line_id THEN

						    
						      
						    CALC_REV_AMOUNT_P(     pi_request_id 	=> g_request_id,
									   pi_order_id   	=> r_rev.order_id,
									   pi_line_id    	=> r_rev.line_id,
									   pi_org_id     	=> r_rev.org_id,
									   pi_tenant_id  	=> r_rev.tenant_id,
									   pi_line_type  	=> r_rev.line_type,
									   pi_unit_price 	=> r_rev.unit_price,
									   pi_quantity   	=> r_rev.ordered_quantity,
									   pi_uom        	=> r_rev.uom,
									   pi_rev_rec_type      => 'Monthly',
									   pi_period_start_date => l_period_start_date,
									   pi_period_end_date   => l_period_end_date,
									   po_rev_amount        => l_rev_amount,
							                   po_unit_price        => l_unit_price) ;
					        
					          l_adjustment := l_rev_amount - k.amount;		                   
						      
				           END IF;
		                    END LOOP;
		                  
		                 ELSE */
		                     --Get Revenue Amount
		                    CALC_REV_AMOUNT_P(     pi_request_id 	=> g_request_id,
							   pi_order_id   	=> r_rev.order_id,
							   pi_line_id    	=> r_rev.line_id,
							   pi_org_id     	=> r_rev.org_id,
							   pi_tenant_id  	=> r_rev.tenant_id,
							   pi_line_type  	=> r_rev.line_type,
							   pi_unit_price 	=> r_rev.unit_price,
							   pi_quantity   	=> r_rev.ordered_quantity,
							   pi_uom        	=> r_rev.uom,
							   pi_rev_rec_type      => 'Monthly',
							   pi_period_start_date => l_period_start_date,
							   pi_period_end_date   => l_period_end_date,
							   po_rev_amount        => l_rev_amount,
							   po_unit_price        => l_unit_price,
							   po_adjustment        => l_adjustment,
							   po_quantity          => l_quantity) ;
		                     
		                --  END IF;
		                  ---
		          
		          l_total_amount := l_total_amount + l_adjustment;
	         	        
			        l_revenue_details(r_sch).rev_sch_id             := REVSCHSEQ.nextval;
			        l_revenue_details(r_sch).rev_allocation_id      := REVALLOCSEQ.currval;
			        l_revenue_details(r_sch).order_id               := r_rev.order_id;
			        l_revenue_details(r_sch).line_id                := r_rev.line_id;
			        l_revenue_details(r_sch).revenue_type           := 'ADJUSTMENT';
			        l_revenue_details(r_sch).revenue_from_date      := l_period_start_date;
			        l_revenue_details(r_sch).revenue_to_date        := l_period_end_date;
			        l_revenue_details(r_sch).revenue_from_period    := l_period_name;
			        l_revenue_details(r_sch).revenue_to_period      := l_period_name;
			        l_revenue_details(r_sch).customer_trx_line_id   := NULL;
			        l_revenue_details(r_sch).revenue_account        := NULL;
			        l_revenue_details(r_sch).ledger                 := NULL;
			        l_revenue_details(r_sch).last_update_date       := SYSDATE;
			        l_revenue_details(r_sch).last_updated_by        := NULL;
			        l_revenue_details(r_sch).creation_date          := SYSDATE;
			        l_revenue_details(r_sch).created_by             := NULL;
			        l_revenue_details(r_sch).percent                := NULL;
			        l_revenue_details(r_sch).amount                 := l_adjustment;
			        l_revenue_details(r_sch).quantity               := l_quantity;
			        l_revenue_details(r_sch).unit_price             := l_unit_price;
			        l_revenue_details(r_sch).adjustment             := l_adjustment;
			        l_revenue_details(r_sch).gl_date                := NULL;
			        l_revenue_details(r_sch).gl_posted_date         := NULL;
			        l_revenue_details(r_sch).cust_trx_line_salesrep := r_rev.salesrep;
			        l_revenue_details(r_sch).attribute_category     := NULL;
			        l_revenue_details(r_sch).attribute1             := NULL;
			        l_revenue_details(r_sch).attribute2             := NULL;
			        l_revenue_details(r_sch).attribute3             := NULL;
			        l_revenue_details(r_sch).attribute4             := NULL;
			        l_revenue_details(r_sch).attribute5             := NULL;
			        l_revenue_details(r_sch).attribute6             := NULL;
			        l_revenue_details(r_sch).attribute7             := NULL;
			        l_revenue_details(r_sch).attribute8             := NULL;
			        l_revenue_details(r_sch).attribute9             := NULL;
			        l_revenue_details(r_sch).attribute10            := NULL;
			        l_revenue_details(r_sch).original_gl_date       := NULL;
			        l_revenue_details(r_sch).account_class          := NULL;
			        l_revenue_details(r_sch).customer_trx_id        := NULL;
			        l_revenue_details(r_sch).acctd_amount           := NULL;
			        l_revenue_details(r_sch).attribute11            := NULL;
			        l_revenue_details(r_sch).attribute12            := NULL;
			        l_revenue_details(r_sch).attribute13            := NULL;
			        l_revenue_details(r_sch).attribute14            := NULL;
			        l_revenue_details(r_sch).attribute15            := NULL;
			        l_revenue_details(r_sch).latest_rec_flag        := NULL;
			        l_revenue_details(r_sch).org_id                 := r_rev.org_id;
			        l_revenue_details(r_sch).revenue_adjustment_id  := NULL;
			        l_revenue_details(r_sch).rec_offset_flag        := NULL;
			        l_revenue_details(r_sch).event_id               := NULL;
			        l_revenue_details(r_sch).user_generated_flag    := NULL;
			        l_revenue_details(r_sch).tenant_id              := r_rev.tenant_id;
			        l_revenue_details(r_sch).legacy_from_date       := NULL;
			        l_revenue_details(r_sch).legacy_to_date         := NULL;
			        l_revenue_details(r_sch).credit_rma_flag        := NULL;
			        l_revenue_details(r_sch).cash_basis_flag        := NULL;
			        l_revenue_details(r_sch).eoc_flag               := NULL;
			        l_revenue_details(r_sch).rev_channel            := NULL;
			        l_revenue_details(r_sch).recognized_rev         := NULL;
			        l_revenue_details(r_sch).unrecognized_rev       := l_adjustment;
			        l_revenue_details(r_sch).actual_rev_effective   := NULL;
			        l_revenue_details(r_sch).calendar_year          := l_period_year;
			        l_revenue_details(r_sch).calendar_month         := l_period_num;
			        l_revenue_details(r_sch).calendar_quarter       := l_period_qtr;
			        l_revenue_details(r_sch).status                 := 'SCHEDULED';
			        l_revenue_details(r_sch).line_type              := r_rev.line_type;
			        l_revenue_details(r_sch).tracking_options       := r_rev.tracking_options;
			        l_revenue_details(r_sch).billing_channel        := r_rev.billing_channel_id;
			        l_revenue_details(r_sch).order_number           := r_rev.order_number;
			        l_revenue_details(r_sch).line_number            := r_rev.line_number;
			        l_revenue_details(r_sch).bonus_flag             := NULL;
			        l_revenue_details(r_sch).fiscal_month           := NULL;
			        l_revenue_details(r_sch).fiscal_quarter         := NULL;
			        l_revenue_details(r_sch).fiscal_year            := NULL;
			        l_revenue_details(r_sch).period_month           := NULL;
			        l_revenue_details(r_sch).revenue_event          := NULL;
			        l_revenue_details(r_sch).revenue_schedule       := l_schedule;
			        l_revenue_details(r_sch).schedule_gen_date      := sysdate;
         
                       END IF; --monthly

		  END LOOP;--r_sch
          
              l_rev_allocations.total_amount := l_total_amount;            
            
            
            ELSE
                    l_rev_allocations.rev_allocation_id := REVALLOCSEQ.nextval;
                    l_rev_allocations.order_id          := r_rev.order_id;
                    l_rev_allocations.line_id           := r_rev.line_id;
                    l_rev_allocations.item_id           := r_rev.item_id;
                    l_rev_allocations.rev_rec_type      := l_schedule;
                    l_rev_allocations.revenue_type      := 'STANDARD';
                    l_rev_allocations.revenue_from_date := NVL(r_rev.rev_start_date,r_rev.effective_start_date);
                    l_rev_allocations.revenue_to_date   := NVL(r_rev.rev_end_date,r_rev.effective_end_date);
                    l_rev_allocations.no_of_months      := ROUND(months_between(NVL(r_rev.rev_end_date, r_rev.effective_end_date), NVL(r_rev.rev_start_date, r_rev.effective_start_date)));
                    l_rev_allocations.quantity          := r_rev.ordered_quantity;
                    l_rev_allocations.unit_price        := r_rev.unit_price;
		   -- l_rev_allocations.total_amount      := round((r_rev.ordered_quantity*r_rev.unit_price),2);
		    l_rev_allocations.accounting_rule   := r_rev.accounting_rule;
                    l_rev_allocations.last_update_date  := sysdate;
                    l_rev_allocations.last_updated_by   := 1;
                    l_rev_allocations.creation_date     := sysdate;
                    l_rev_allocations.created_by        := 1;
		    l_rev_allocations.ATTRIBUTE_CATEGORY := NULL;
		    l_rev_allocations.ATTRIBUTE1         := NULL;
		    l_rev_allocations.ATTRIBUTE2 	      := NULL;
		    l_rev_allocations.ATTRIBUTE3 	      := NULL;
		    l_rev_allocations.ATTRIBUTE4 	      := NULL;
		    l_rev_allocations.ATTRIBUTE5 	      := NULL;
		    l_rev_allocations.ATTRIBUTE6 	      := NULL;
		    l_rev_allocations.ATTRIBUTE7 	      := NULL;
		    l_rev_allocations.ATTRIBUTE8 	      := NULL;
		    l_rev_allocations.ATTRIBUTE9 	      := NULL;
		    l_rev_allocations.ATTRIBUTE10	      := NULL;
		    l_rev_allocations.ATTRIBUTE11	      := NULL;
		    l_rev_allocations.ATTRIBUTE12	      := NULL;
		    l_rev_allocations.ATTRIBUTE13	      := NULL;
		    l_rev_allocations.ATTRIBUTE14	      := NULL;
		    l_rev_allocations.ATTRIBUTE15	      := NULL;  
                    l_rev_allocations.tenant_id               := r_rev.tenant_id;
                    l_rev_allocations.org_id                  := r_rev.org_id;
		    
		       IF l_schedule = 'MONTHLY' THEN
			   l_no_of_months := ROUND(months_between(NVL(r_rev.rev_end_date, r_rev.effective_end_date), NVL(r_rev.rev_start_date, r_rev.effective_start_date)));

			   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_rev_schedule) : Number of Months  '|| l_no_of_months, 'Y', 0);

			   IF l_no_of_months > 0 THEN
			      l_loop_count := l_no_of_months;
			   END IF;
		     END IF;     --  IF l_schedule = 'MONTHLY' THEN   
		     
		     ----
	  		     
		  l_revenue_details.DELETE;
		  FOR  r_sch IN 1..l_loop_count LOOP
		  
		                 IF l_schedule = 'MONTHLY' THEN
		                 
		                 
		                               l_start_date := ADD_MONTHS(NVL(r_rev.rev_start_date,r_rev.effective_start_date),(r_sch-1));
		                              
		                              GET_CALENDAR_DETAILS(pi_date            =>l_start_date,
				                                   pi_tenant_id       =>pi_tenant_id,
				                                   po_start_date      =>l_period_start_date,
				                                   po_end_Date        =>l_period_end_date,
				                                   po_period_name     =>l_period_name,
				                                   po_period_num      =>l_period_num,
				                                   po_period_qtr      =>l_period_qtr,
				                                   po_period_year     =>l_period_year,
				                                   po_period_set_name =>l_period_set
                                                                  );
		
					  --check if start date is not first day of the month.
					  IF l_period_name = to_char(l_start_date, 'MON-RR') AND l_period_start_date <> l_start_date THEN
					     l_period_start_date :=l_start_date;
		                          END IF;
		        
		        		                          
		                          --check for last period
		                          IF l_period_name = to_char(NVL(r_rev.rev_end_date,r_rev.effective_end_date), 'MON-RR') THEN
		                             l_period_end_date :=NVL(r_rev.rev_end_date,r_rev.effective_end_date);
		                          END IF;
		                  
		         /*         -- Check if amount was changed in middle of contract
		                 IF r_rev.attribute1_d IS NOT NULL and l_period_start_date<r_rev.attribute1_d THEN 
		                  FOR k in l_old_sch_rec.COUNT LOOP
		                    IF l_period_start_date = k.revenue_from_date AND l_period_end_date =k.revenue_period_end_date
		                       AND r_rev.order_id = k.order_id and r_rev.line_id = k.line_id THEN
		                       
		                      l_rev_amount := k.amount;
		                      l_unit_price := l.unit_price;
		                    --  l_adjustment := r_rev.unit_price - k.unit_price;
		                  END IF;
		                  END LOOP;
		                  
		                  ELSIF r_rev.attribute1_d IS NOT NULL and l_period_start_date>=r_rev.attribute1_d THEN 
		                     FOR k in l_old_sch_rec.COUNT LOOP
				          IF l_period_start_date = k.revenue_from_date AND l_period_end_date =k.revenue_period_end_date
						AND r_rev.order_id = k.order_id and r_rev.line_id = k.line_id THEN

						    
						      
						    CALC_REV_AMOUNT_P(     pi_request_id 	=> g_request_id,
									   pi_order_id   	=> r_rev.order_id,
									   pi_line_id    	=> r_rev.line_id,
									   pi_org_id     	=> r_rev.org_id,
									   pi_tenant_id  	=> r_rev.tenant_id,
									   pi_line_type  	=> r_rev.line_type,
									   pi_unit_price 	=> r_rev.unit_price,
									   pi_quantity   	=> r_rev.ordered_quantity,
									   pi_uom        	=> r_rev.uom,
									   pi_rev_rec_type      => 'Monthly',
									   pi_period_start_date => l_period_start_date,
									   pi_period_end_date   => l_period_end_date,
									   po_rev_amount        => l_rev_amount,
							                   po_unit_price        => l_unit_price) ;
					        
					          l_adjustment := l_rev_amount - k.amount;		                   
						      
				           END IF;
		                    END LOOP;
		                  
		                 ELSE */
		                     --Get Revenue Amount
		                    CALC_REV_AMOUNT_P(     pi_request_id 	=> g_request_id,
							   pi_order_id   	=> r_rev.order_id,
							   pi_line_id    	=> r_rev.line_id,
							   pi_org_id     	=> r_rev.org_id,
							   pi_tenant_id  	=> r_rev.tenant_id,
							   pi_line_type  	=> r_rev.line_type,
							   pi_unit_price 	=> r_rev.unit_price,
							   pi_quantity   	=> r_rev.ordered_quantity,
							   pi_uom        	=> r_rev.uom,
							   pi_rev_rec_type      => 'Monthly',
							   pi_period_start_date => l_period_start_date,
							   pi_period_end_date   => l_period_end_date,
							   po_rev_amount        => l_rev_amount,
							   po_unit_price        => l_unit_price,
							   po_adjustment        => l_adjustment,
							   po_quantity          => l_quantity) ;
		                     
		                --  END IF;
		                  ---
		          
		          l_total_amount := l_total_amount + l_rev_amount;
	         	        
			        l_revenue_details(r_sch).rev_sch_id             := REVSCHSEQ.nextval;
			        l_revenue_details(r_sch).rev_allocation_id      := REVALLOCSEQ.currval;
			        l_revenue_details(r_sch).order_id               := r_rev.order_id;
			        l_revenue_details(r_sch).line_id                := r_rev.line_id;
			        l_revenue_details(r_sch).revenue_type           := 'STANDARD';
			        l_revenue_details(r_sch).revenue_from_date      := l_period_start_date;
			        l_revenue_details(r_sch).revenue_to_date        := l_period_end_date;
			        l_revenue_details(r_sch).revenue_from_period    := l_period_name;
			        l_revenue_details(r_sch).revenue_to_period      := l_period_name;
			        l_revenue_details(r_sch).customer_trx_line_id   := NULL;
			        l_revenue_details(r_sch).revenue_account        := NULL;
			        l_revenue_details(r_sch).ledger                 := NULL;
			        l_revenue_details(r_sch).last_update_date       := SYSDATE;
			        l_revenue_details(r_sch).last_updated_by        := NULL;
			        l_revenue_details(r_sch).creation_date          := SYSDATE;
			        l_revenue_details(r_sch).created_by             := NULL;
			        l_revenue_details(r_sch).percent                := NULL;
			        l_revenue_details(r_sch).amount                 := l_rev_amount;
			        l_revenue_details(r_sch).quantity               := l_quantity;
			        l_revenue_details(r_sch).unit_price             := l_unit_price;
			        l_revenue_details(r_sch).adjustment             := l_adjustment;
			        l_revenue_details(r_sch).gl_date                := NULL;
			        l_revenue_details(r_sch).gl_posted_date         := NULL;
			        l_revenue_details(r_sch).cust_trx_line_salesrep := r_rev.salesrep;
			        l_revenue_details(r_sch).attribute_category     := NULL;
			        l_revenue_details(r_sch).attribute1             := NULL;
			        l_revenue_details(r_sch).attribute2             := NULL;
			        l_revenue_details(r_sch).attribute3             := NULL;
			        l_revenue_details(r_sch).attribute4             := NULL;
			        l_revenue_details(r_sch).attribute5             := NULL;
			        l_revenue_details(r_sch).attribute6             := NULL;
			        l_revenue_details(r_sch).attribute7             := NULL;
			        l_revenue_details(r_sch).attribute8             := NULL;
			        l_revenue_details(r_sch).attribute9             := NULL;
			        l_revenue_details(r_sch).attribute10            := NULL;
			        l_revenue_details(r_sch).original_gl_date       := NULL;
			        l_revenue_details(r_sch).account_class          := NULL;
			        l_revenue_details(r_sch).customer_trx_id        := NULL;
			        l_revenue_details(r_sch).acctd_amount           := NULL;
			        l_revenue_details(r_sch).attribute11            := NULL;
			        l_revenue_details(r_sch).attribute12            := NULL;
			        l_revenue_details(r_sch).attribute13            := NULL;
			        l_revenue_details(r_sch).attribute14            := NULL;
			        l_revenue_details(r_sch).attribute15            := NULL;
			        l_revenue_details(r_sch).latest_rec_flag        := NULL;
			        l_revenue_details(r_sch).org_id                 := r_rev.org_id;
			        l_revenue_details(r_sch).revenue_adjustment_id  := NULL;
			        l_revenue_details(r_sch).rec_offset_flag        := NULL;
			        l_revenue_details(r_sch).event_id               := NULL;
			        l_revenue_details(r_sch).user_generated_flag    := NULL;
			        l_revenue_details(r_sch).tenant_id              := r_rev.tenant_id;
			        l_revenue_details(r_sch).legacy_from_date       := NULL;
			        l_revenue_details(r_sch).legacy_to_date         := NULL;
			        l_revenue_details(r_sch).credit_rma_flag        := NULL;
			        l_revenue_details(r_sch).cash_basis_flag        := NULL;
			        l_revenue_details(r_sch).eoc_flag               := NULL;
			        l_revenue_details(r_sch).rev_channel            := NULL;
			        l_revenue_details(r_sch).recognized_rev         := NULL;
			        l_revenue_details(r_sch).unrecognized_rev       := l_rev_amount;
			        l_revenue_details(r_sch).actual_rev_effective   := NULL;
			        l_revenue_details(r_sch).calendar_year          := l_period_year;
			        l_revenue_details(r_sch).calendar_month         := l_period_num;
			        l_revenue_details(r_sch).calendar_quarter       := l_period_qtr;
			        l_revenue_details(r_sch).status                 := 'SCHEDULED';
			        l_revenue_details(r_sch).line_type              := r_rev.line_type;
			        l_revenue_details(r_sch).tracking_options       := r_rev.tracking_options;
			        l_revenue_details(r_sch).billing_channel        := r_rev.billing_channel_id;
			        l_revenue_details(r_sch).order_number           := r_rev.order_number;
			        l_revenue_details(r_sch).line_number            := r_rev.line_number;
			        l_revenue_details(r_sch).bonus_flag             := NULL;
			        l_revenue_details(r_sch).fiscal_month           := NULL;
			        l_revenue_details(r_sch).fiscal_quarter         := NULL;
			        l_revenue_details(r_sch).fiscal_year            := NULL;
			        l_revenue_details(r_sch).period_month           := NULL;
			        l_revenue_details(r_sch).revenue_event          := NULL;
			        l_revenue_details(r_sch).revenue_schedule       := l_schedule;
			        l_revenue_details(r_sch).schedule_gen_date      := sysdate;
         
                       END IF; --monthly

		  END LOOP;--r_sch
          
              l_rev_allocations.total_amount := l_total_amount;
              
              END IF;
		  
		          UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_schedules) : Call INSERT_REVENUE_DETAILS Proc : ', 'Y', 0);
		          
		          CREATE_REV_ALLOCATION (l_rev_allocations,g_request_id);
		  
		          UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_schedules) : Call INSERT_REVENUE_DETAILS Proc : ', 'Y', 0);
		  			  
			  INSERT_REVENUE_DETAILS(l_revenue_details, g_request_id);
			  
		                                
		          
		END LOOP; --r_rev  
		     

		    UTILITY_PKG.update_conc_request(g_request_id, 'C', 'C', 'Completed', SYSDATE);
            COMMIT;
          
 EXCEPTION
   WHEN OTHERS THEN

       UTILITY_PKG.write_log(pi_request_id,'Unexpected Exception'||SQLERRM, 'Y', 0);
       UTILITY_PKG.update_conc_request(pi_request_id, 'C', 'E', 'Error', SYSDATE);

  END GENERATE_REV_SCHEDULE;
  
PROCEDURE REV_RECOG_P       (
                                   pi_errbuf     OUT VARCHAR2,
                                   pi_retcode    OUT VARCHAR2,
                                   pi_request_id IN NUMBER,
			           pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER,
			           pi_from_date  IN DATE,
			           pi_to_date    IN DATE,
			           pi_period     IN VARCHAR2)
IS
CURSOR c_rev_rec IS
   SELECT * 
     FROM order_revenue_details_all
     WHERE status = 'SCHEDULED'
       AND order_id = NVL(pi_order_id, order_id)
       AND line_id  = NVL(pi_line_id, line_id)
       AND org_id   = NVL(pi_org_id,org_id)
       AND tenant_id = NVL(pi_tenant_id, tenant_id)
       AND ((pi_from_date BETWEEN revenue_from_date and revenue_to_date
            AND pi_to_date BETWEEN revenue_from_date and revenue_to_date)
            OR (revenue_from_period = pi_period AND revenue_to_period = pi_period))
        FOR UPDATE nowait    ;

l_rev_rec_exist VARCHAR2(3);
l_rev_rec t_rev_rec;
l_rec NUMBER;

BEGIN
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.REV_RECOG_P) : *** Start ***', 'Y', 0);
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.REV_RECOG_P) : Parameters... pi_request_id: '
                                            ||pi_request_id||' | '||'pi_tenant_id: '||pi_tenant_id||' | '||'pi_org_id: '||pi_org_id||' | '||'p_order_id: '||pi_order_id
                                            ||' | '||' pi_line_id: '||pi_line_id
                                            ||' | '||' pi_from_date: '||pi_from_date
                                            ||' | '||' pi_to_date: '||pi_to_date
                                            ||' | '||' pi_period: '||pi_period, 'Y', 0);

   g_request_id := pi_request_id;
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Before Rev Rec Cursor ***', 'Y', 0);
   l_rec:= 0;
   FOR i in c_rev_rec LOOP
	   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Check if Revenue Already recognized ***', 'Y', 0);
	   l_rev_rec_exist := 'N';
	   
	   BEGIN
	     SELECT 'Y' 
	       INTO l_rev_rec_exist
	       FROM ORDER_REV_REC_DETAILS_ALL rev
	      WHERE rev.order_id  = i.order_id 
		AND rev.line_id   = i.line_id
		AND rev.org_id    = i.org_id
		AND rev.tenant_id = i.tenant_id
		AND rev.rev_sch_id = i.rev_sch_id
		AND rev.revenue_from_period = i.revenue_from_period
		AND rev.revenue_to_period = i.revenue_to_period
		AND rev.status    = 'RECOGNIZED';
	     EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   l_rev_rec_exist := 'N';
		WHEN OTHERS THEN
		   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Unexpected Error while checking rev rec record exist ***'||SQLERRM, 'Y', 0);
		   pi_errbuf := SQLERRM;
		   pi_retcode := 2;
	   END; 
   
	   IF l_rev_rec_exist ='N' THEN
         l_rec:=l_rec+1;
			l_rev_rec(l_rec).rev_rec_id             := REVRECSEQ.nextval;
			l_rev_rec(l_rec).rev_sch_id             := i.rev_sch_id;
			l_rev_rec(l_rec).order_id               := i.order_id ;             
			l_rev_rec(l_rec).line_id                := i.line_id   ;            
			l_rev_rec(l_rec).revenue_type           := i.revenue_type;          
			l_rev_rec(l_rec).revenue_from_date      := i.revenue_from_date ;    
			l_rev_rec(l_rec).revenue_to_date        := i.revenue_to_date   ;    
			l_rev_rec(l_rec).revenue_from_period    := i.revenue_from_period;   
			l_rev_rec(l_rec).revenue_to_period      := i.revenue_to_period  ;   
			l_rev_rec(l_rec).customer_trx_line_id   := i.customer_trx_line_id;  
			l_rev_rec(l_rec).revenue_account        := i.revenue_account     ;  
			l_rev_rec(l_rec).ledger                 := i.ledger              ;  
			l_rev_rec(l_rec).last_update_date       := sysdate       ;  
			l_rev_rec(l_rec).last_updated_by        := -1            ;  
			l_rev_rec(l_rec).creation_date          := sysdate       ;  
			l_rev_rec(l_rec).created_by             := -1            ;            
			l_rev_rec(l_rec).percent                := i.percent   ;            
			l_rev_rec(l_rec).amount                 := i.amount    ;            
			l_rev_rec(l_rec).quantity               := i.quantity  ; 
			l_rev_rec(l_rec).unit_price             := i.unit_price  ; 
			l_rev_rec(l_rec).adjustment             := i.adjustment  ; 
			l_rev_rec(l_rec).gl_date                := i.gl_date   ;            
			l_rev_rec(l_rec).gl_posted_date         := i.gl_posted_date;        
			l_rev_rec(l_rec).cust_trx_line_salesrep := i.cust_trx_line_salesrep;
			l_rev_rec(l_rec).attribute_category     := i.attribute_category    ;
			l_rev_rec(l_rec).attribute1             := i.attribute1            ;
			l_rev_rec(l_rec).attribute2             := i.attribute2            ;
			l_rev_rec(l_rec).attribute3             := i.attribute3            ;
			l_rev_rec(l_rec).attribute4             := i.attribute4            ;
			l_rev_rec(l_rec).attribute5             := i.attribute5            ;
			l_rev_rec(l_rec).attribute6             := i.attribute6            ;
			l_rev_rec(l_rec).attribute7             := i.attribute7            ;
			l_rev_rec(l_rec).attribute8             := i.attribute8            ;
			l_rev_rec(l_rec).attribute9             := i.attribute9            ;
			l_rev_rec(l_rec).attribute10            := i.attribute10           ;
			l_rev_rec(l_rec).original_gl_date       := i.original_gl_date      ;
			l_rev_rec(l_rec).account_class          := i.account_class         ;
			l_rev_rec(l_rec).customer_trx_id        := i.customer_trx_id       ;
			l_rev_rec(l_rec).acctd_amount           := i.amount                ;
			l_rev_rec(l_rec).attribute11            := i.attribute11           ;
			l_rev_rec(l_rec).attribute12            := i.attribute12           ;
			l_rev_rec(l_rec).attribute13            := i.attribute13           ;
			l_rev_rec(l_rec).attribute14            := i.attribute14           ;
			l_rev_rec(l_rec).attribute15            := i.attribute15           ;
			l_rev_rec(l_rec).latest_rec_flag        := i.latest_rec_flag       ;
			l_rev_rec(l_rec).org_id                 := i.org_id                ;
			l_rev_rec(l_rec).revenue_adjustment_id  := i.revenue_adjustment_id ;
			l_rev_rec(l_rec).rec_offset_flag        := i.rec_offset_flag       ;
			l_rev_rec(l_rec).event_id               := i.event_id              ;
			l_rev_rec(l_rec).user_generated_flag    := i.user_generated_flag   ;
			l_rev_rec(l_rec).tenant_id              := i.tenant_id             ;
			l_rev_rec(l_rec).legacy_from_date       := i.legacy_from_date      ;
			l_rev_rec(l_rec).legacy_to_date         := i.legacy_to_date        ;
			l_rev_rec(l_rec).credit_rma_flag        := i.credit_rma_flag       ;
			l_rev_rec(l_rec).cash_basis_flag        := i.cash_basis_flag       ;
			l_rev_rec(l_rec).eoc_flag               := i.eoc_flag              ;
			l_rev_rec(l_rec).rev_channel            := i.rev_channel           ;
			l_rev_rec(l_rec).recognized_rev         := i.amount                ;
			l_rev_rec(l_rec).unrecognized_rev       := 0                       ;
			l_rev_rec(l_rec).actual_rev_effective   := i.calendar_month                 ;
			l_rev_rec(l_rec).calendar_year          := i.calendar_year         ;
			l_rev_rec(l_rec).calendar_month         := i.calendar_month        ;
			l_rev_rec(l_rec).calendar_quarter       := i.calendar_quarter      ;
			l_rev_rec(l_rec).status                 := 'RECOGNIZED'            ;
			l_rev_rec(l_rec).line_type              := i.line_type             ;
			l_rev_rec(l_rec).tracking_options       := i.tracking_options;
			l_rev_rec(l_rec).billing_channel        := i.billing_channel ;     
			l_rev_rec(l_rec).order_number           := i.order_number    ;     
			l_rev_rec(l_rec).line_number            := i.line_number     ;     
			l_rev_rec(l_rec).bonus_flag             := i.bonus_flag      ;     
			l_rev_rec(l_rec).fiscal_month           := i.fiscal_month    ;     
			l_rev_rec(l_rec).fiscal_quarter         := i.fiscal_quarter  ;     
			l_rev_rec(l_rec).fiscal_year            := i.fiscal_year     ;     
			l_rev_rec(l_rec).period_month           := i.period_month    ;     
			l_rev_rec(l_rec).revenue_event          := i.revenue_event   ;     
			l_rev_rec(l_rec).revenue_schedule       := i.revenue_schedule;


                  UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Updating satus to Recognized in order revenue details all table for order id ***'||i.order_id||' line id '||i.line_id||' rev sch id'||i.rev_sch_id, 'Y', 0);


                       UPDATE order_revenue_details_all
                          SET status = 'RECOGNIZED'
                        WHERE rev_sch_id = i.rev_sch_id
                          AND order_id   = i.order_id
	                  AND line_id    = i.line_id
	                  AND org_id     = i.org_id
                          AND tenant_id  = i.tenant_id;

	   END IF;
   
   
   
   
   END LOOP;
   
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Calling INSERT_REV_REC_DETAILS Procedure  ***', 'Y', 0);

   INSERT_REV_REC_DETAILS(l_rev_rec, g_request_id);
   
   IF pi_retcode=2 THEN
     pi_errbuf:='Error';
   END IF;  
   
   COMMIT;
 EXCEPTION  
WHEN OTHERS THEN
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG) : *** Unexpected Error while checking rev rec record exist ***'||SQLERRM, 'Y', 0);
   pi_errbuf := 'Error';
   pi_retcode := 2;   

END REV_RECOG_P;

 PROCEDURE TERMINATE_CONTRACT_REV_P (
                                   pi_errbuf     OUT VARCHAR2,
                                   pi_retcode    OUT VARCHAR2,
                                   pi_request_id IN NUMBER,
			           pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER)
IS
  CURSOR c_terminate_rev_lines (pi_order_id NUMBER,pi_line_id NUMBER,pi_org_id NUMBER,pi_tenant_id NUMBER)
  IS
      SELECT ola.order_id,
             ola.line_id,
             ola.org_id, 
             ola.tenant_id,
             ola.termination_date,
             ola.ordered_quantity,
             ola.unit_price,
             ola.accounting_rule,
             ola.line_type,
             ola.uom,
             ola.item_id,
             ola.rev_end_date,
             ola.effective_end_date
	FROM order_lines_all ola
       WHERE 1=1
	 AND NVL (ola.stop_billing, 'N') <> 'Y'
	 AND NVL (ola.billing_complete, 'N') <> 'Y'
	 AND ola.order_id = NVL(pi_order_id, ola.order_id)
	 AND ola.line_id = NVL(pi_line_id, ola.line_id)
	 AND NVL (ola.org_id, -1) =
		DECODE (pi_org_id,
			NULL, NVL (ola.org_id, -1),
			pi_org_id
		       )
	AND ola.tenant_id  = NVL(pi_tenant_id,ola.tenant_id) 
	AND ola.status IN ( 'CANCELED','TERMINATED')
	AND NOT EXISTS (SELECT 'Y' FROM ORDER_REVENUE_DETAILS_ALL rev
			 WHERE ola.order_id  = rev.order_id
			   AND ola.line_id   = rev.line_id
			   AND ola.org_id    = rev.org_id
			   AND ola.tenant_id = rev.tenant_id
			   AND rev.status    = 'CANCELED')
			  FOR UPDATE nowait ;

CURSOR c_rev_sch (p_order_id NUMBER, p_line_id NUMBER, p_tenant_id NUMBER, p_org_id NUMBER,p_termination_date DATE) 
IS 
     SELECT *
       FROM order_revenue_details_all
      WHERE order_id = p_order_id
        AND line_id = p_line_id
        AND NVL (org_id, -1) =
		DECODE (p_org_id,
			NULL, NVL (org_id, -1),
			p_org_id
		       )
	AND tenant_id = p_tenant_id
	AND revenue_from_date >= p_termination_date;
	
	l_rec_count NUMBER;
  l_revenue_details   t_revenue_schedules;
  l_rev_allocations   ORDER_REV_ALLOCATIONS_ALL%ROWTYPE;
  l_schedule VARCHAR2(30);
  l_total_amount NUMBER;
BEGIN

 UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : *** Terminate Revenue Schedules  ***', 'Y', 0);
 UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : Parameters... pi_request_id: '
                                             ||pi_request_id||' | '||'pi_tenant_id: '||pi_tenant_id||' | '||'pi_org_id: '||pi_org_id||' | '||'p_order_id: '||pi_order_id
                                             ||' | '||' pi_line_id: '||pi_line_id, 'Y', 0);
 
    g_request_id := pi_request_id;
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : *** Before terminate Cursor ***', 'Y', 0);


FOR r_rev in c_terminate_rev_lines(pi_order_id ,pi_line_id,pi_org_id ,pi_tenant_id)
LOOP
 
       BEGIN
       SELECT UPPER(rev_schedule)
                 INTO  l_schedule
                 FROM ar_accounting_rules
                WHERE 1 = 1
                  AND UPPER(name) = UPPER(r_rev.accounting_rule)
                  AND tenant_id = pi_tenant_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  
                   l_schedule := NULL;
                  
                   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : Accounting rule :'|| r_rev.accounting_rule||' not defined in lookup', 'Y', 0);
               WHEN OTHERS THEN
                
                   l_schedule := NULL;
                 
                   UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : Unknown exception while fetching accounting rule details :'|| SQLERRM, 'Y', 0);
            END;

              l_rev_allocations.rev_allocation_id := REVALLOCSEQ.nextval;
                    l_rev_allocations.order_id          := r_rev.order_id;
                    l_rev_allocations.line_id           := r_rev.line_id;
                    l_rev_allocations.item_id           := r_rev.item_id;
                    l_rev_allocations.rev_rec_type      := l_schedule;
                    l_rev_allocations.revenue_type      := 'AMENDMENT';
                    l_rev_allocations.revenue_from_date := r_rev.termination_date;
                    l_rev_allocations.revenue_to_date   := NVL(r_rev.rev_end_date,r_rev.effective_end_date);
                    l_rev_allocations.no_of_months      := ROUND(months_between(NVL(r_rev.rev_end_date, r_rev.effective_end_date), r_rev.termination_date));
                    l_rev_allocations.quantity          := r_rev.ordered_quantity;
                    l_rev_allocations.unit_price        := r_rev.unit_price;
		   -- l_rev_allocations.total_amount      := round((r_rev.ordered_quantity*r_rev.unit_price),2);
		    l_rev_allocations.accounting_rule   := r_rev.accounting_rule;
                    l_rev_allocations.last_update_date  := sysdate;
                    l_rev_allocations.last_updated_by   := 1;
                    l_rev_allocations.creation_date     := sysdate;
                    l_rev_allocations.created_by        := 1;
		    l_rev_allocations.ATTRIBUTE_CATEGORY := NULL;
		    l_rev_allocations.ATTRIBUTE1         := NULL;
		    l_rev_allocations.ATTRIBUTE2 	 := NULL;
		    l_rev_allocations.ATTRIBUTE3 	 := NULL;
		    l_rev_allocations.ATTRIBUTE4 	 := NULL;
		    l_rev_allocations.ATTRIBUTE5 	 := NULL;
		    l_rev_allocations.ATTRIBUTE6 	 := NULL;
		    l_rev_allocations.ATTRIBUTE7 	 := NULL;
		    l_rev_allocations.ATTRIBUTE8 	 := NULL;
		    l_rev_allocations.ATTRIBUTE9 	 := NULL;
		    l_rev_allocations.ATTRIBUTE10	 := NULL;
		    l_rev_allocations.ATTRIBUTE11	 := NULL;
		    l_rev_allocations.ATTRIBUTE12	 := NULL;
		    l_rev_allocations.ATTRIBUTE13	 := NULL;
		    l_rev_allocations.ATTRIBUTE14	 := NULL;
		    l_rev_allocations.ATTRIBUTE15	 := NULL;  
                    l_rev_allocations.tenant_id          := r_rev.tenant_id;
                    l_rev_allocations.org_id             := r_rev.org_id;
		    
	          l_rec_count := 0;
		  FOR  r_rev_sch IN c_rev_sch(r_rev.order_id,r_rev.line_id,r_rev.tenant_id,r_rev.org_id,r_rev.termination_date)
		  LOOP
		  
		             
		          
		          l_total_amount := l_total_amount - r_rev_sch.amount;
		          l_rec_count := l_rec_count +1;
	         	        
			        l_revenue_details(l_rec_count).rev_sch_id             := REVSCHSEQ.nextval;
			        l_revenue_details(l_rec_count).rev_allocation_id      := REVALLOCSEQ.currval;
			        l_revenue_details(l_rec_count).order_id               := r_rev_sch.order_id;
			        l_revenue_details(l_rec_count).line_id                := r_rev_sch.line_id;
			        l_revenue_details(l_rec_count).revenue_type           := 'ADJUSTMENT';
			        l_revenue_details(l_rec_count).revenue_from_date      := r_rev_sch.revenue_from_date;
			        l_revenue_details(l_rec_count).revenue_to_date        := r_rev_sch.revenue_to_date;
			        l_revenue_details(l_rec_count).revenue_from_period    := r_rev_sch.revenue_from_period ;
			        l_revenue_details(l_rec_count).revenue_to_period      := r_rev_sch.revenue_to_period;
			        l_revenue_details(l_rec_count).customer_trx_line_id   := NULL;
			        l_revenue_details(l_rec_count).revenue_account        := NULL;
			        l_revenue_details(l_rec_count).ledger                 := NULL;
			        l_revenue_details(l_rec_count).last_update_date       := SYSDATE;
			        l_revenue_details(l_rec_count).last_updated_by        := NULL;
			        l_revenue_details(l_rec_count).creation_date          := SYSDATE;
			        l_revenue_details(l_rec_count).created_by             := NULL;
			        l_revenue_details(l_rec_count).percent                := NULL;
			        l_revenue_details(l_rec_count).amount                 := (-1*(r_rev_sch.amount));
			        l_revenue_details(l_rec_count).quantity               := r_rev_sch.quantity;
			        l_revenue_details(l_rec_count).unit_price             := r_rev_sch.unit_price;
			        l_revenue_details(l_rec_count).adjustment             := null;
			        l_revenue_details(l_rec_count).gl_date                := NULL;
			        l_revenue_details(l_rec_count).gl_posted_date         := NULL;
			        l_revenue_details(l_rec_count).cust_trx_line_salesrep := r_rev_sch.cust_trx_line_salesrep;
			        l_revenue_details(l_rec_count).attribute_category     := NULL;
			        l_revenue_details(l_rec_count).attribute1             := NULL;
			        l_revenue_details(l_rec_count).attribute2             := NULL;
			        l_revenue_details(l_rec_count).attribute3             := NULL;
			        l_revenue_details(l_rec_count).attribute4             := NULL;
			        l_revenue_details(l_rec_count).attribute5             := NULL;
			        l_revenue_details(l_rec_count).attribute6             := NULL;
			        l_revenue_details(l_rec_count).attribute7             := NULL;
			        l_revenue_details(l_rec_count).attribute8             := NULL;
			        l_revenue_details(l_rec_count).attribute9             := NULL;
			        l_revenue_details(l_rec_count).attribute10            := NULL;
			        l_revenue_details(l_rec_count).original_gl_date       := NULL;
			        l_revenue_details(l_rec_count).account_class          := NULL;
			        l_revenue_details(l_rec_count).customer_trx_id        := NULL;
			        l_revenue_details(l_rec_count).acctd_amount           := NULL;
			        l_revenue_details(l_rec_count).attribute11            := NULL;
			        l_revenue_details(l_rec_count).attribute12            := NULL;
			        l_revenue_details(l_rec_count).attribute13            := NULL;
			        l_revenue_details(l_rec_count).attribute14            := NULL;
			        l_revenue_details(l_rec_count).attribute15            := NULL;
			        l_revenue_details(l_rec_count).latest_rec_flag        := NULL;
			        l_revenue_details(l_rec_count).org_id                 := r_rev_sch.org_id;
			        l_revenue_details(l_rec_count).revenue_adjustment_id  := NULL;
			        l_revenue_details(l_rec_count).rec_offset_flag        := NULL;
			        l_revenue_details(l_rec_count).event_id               := NULL;
			        l_revenue_details(l_rec_count).user_generated_flag    := NULL;
			        l_revenue_details(l_rec_count).tenant_id              := r_rev_sch.tenant_id;
			        l_revenue_details(l_rec_count).legacy_from_date       := NULL;
			        l_revenue_details(l_rec_count).legacy_to_date         := NULL;
			        l_revenue_details(l_rec_count).credit_rma_flag        := NULL;
			        l_revenue_details(l_rec_count).cash_basis_flag        := NULL;
			        l_revenue_details(l_rec_count).eoc_flag               := NULL;
			        l_revenue_details(l_rec_count).rev_channel            := NULL;
			        l_revenue_details(l_rec_count).recognized_rev         := NULL;
			        l_revenue_details(l_rec_count).unrecognized_rev       := r_rev_sch.amount;
			        l_revenue_details(l_rec_count).actual_rev_effective   := NULL;
			        l_revenue_details(l_rec_count).calendar_year          := r_rev_sch.calendar_year;
			        l_revenue_details(l_rec_count).calendar_month         := r_rev_sch.calendar_month;
			        l_revenue_details(l_rec_count).calendar_quarter       := r_rev_sch.calendar_quarter;
			        l_revenue_details(l_rec_count).status                 := 'CANCELLED';
			        l_revenue_details(l_rec_count).line_type              := r_rev_sch.line_type;
			        l_revenue_details(l_rec_count).tracking_options       := r_rev_sch.tracking_options;
			        l_revenue_details(l_rec_count).billing_channel        := r_rev_sch.billing_channel;
			        l_revenue_details(l_rec_count).order_number           := r_rev_sch.order_number;
			        l_revenue_details(l_rec_count).line_number            := r_rev_sch.line_number;
			        l_revenue_details(l_rec_count).bonus_flag             := NULL;
			        l_revenue_details(l_rec_count).fiscal_month           := NULL;
			        l_revenue_details(l_rec_count).fiscal_quarter         := NULL;
			        l_revenue_details(l_rec_count).fiscal_year            := NULL;
			        l_revenue_details(l_rec_count).period_month           := NULL;
			        l_revenue_details(l_rec_count).revenue_event          := NULL;
			        l_revenue_details(l_rec_count).revenue_schedule       := r_rev_sch.revenue_schedule;
			        l_revenue_details(l_rec_count).schedule_gen_date      := sysdate;
         
   

		  END LOOP;--r_sch
          
              l_rev_allocations.total_amount := l_total_amount;            

		          UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_schedules) : Call INSERT_REVENUE_DETAILS Proc : ', 'Y', 0);
		          
		          CREATE_REV_ALLOCATION (l_rev_allocations,g_request_id);
		  
		          UTILITY_PKG.write_log(pi_request_id,'** Revenue Engine (GEN_REV_SCH_PKG.generate_schedules) : Call INSERT_REVENUE_DETAILS Proc : ', 'Y', 0);
		  			  
			  INSERT_REVENUE_DETAILS(l_revenue_details, g_request_id);
			  COMMIT;  
		                                
		          
		END LOOP; --r_rev  
		     

	   UTILITY_PKG.update_conc_request(g_request_id, 'C', 'C', 'Completed', SYSDATE);
     
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : *** Updating Order Revenue Details all table ***pi_order_id: '||pi_order_id
                                            ||' | '||' pi_line_id: '||pi_line_id, 'Y', 0);


EXCEPTION
WHEN OTHERS THEN
   UTILITY_PKG.write_log(pi_request_id, '** Revenue Engine (GEN_REV_SCH_PKG.TERMINATE_CONTRACT_REV_P) : *** Unexpected Error  ***'||SQLERRM, 'Y', 0);
   pi_errbuf := 'Error';
   pi_retcode := 2;  

END TERMINATE_CONTRACT_REV_P;
  
  		             
END GEN_REV_SCH_PKG;
