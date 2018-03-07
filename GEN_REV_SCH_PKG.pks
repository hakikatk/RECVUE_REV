/*==========================================================================+
|            Recvue Inc. Palo Alto , CA                                     |
+===========================================================================+
|                                                                           |
|  File Name:      GEN_REV_SCH_PKG.pks                                      |
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

CREATE OR REPLACE PACKAGE GEN_REV_SCH_PKG AS

  TYPE t_revenue_schedules IS TABLE OF ORDER_REVENUE_DETAILS_ALL%ROWTYPE INDEX BY BINARY_INTEGER;
  
  TYPE t_rev_rec IS TABLE OF ORDER_REV_REC_DETAILS_ALL%ROWTYPE INDEX BY BINARY_INTEGER;
	
  PROCEDURE CREATE_REV_ALLOCATION(p_rev_allocations IN OUT NOCOPY ORDER_REV_ALLOCATIONS_ALL%ROWTYPE, pi_request_id IN NUMBER);

	
  PROCEDURE INSERT_REVENUE_DETAILS(p_revenue_details IN t_revenue_schedules, pi_request_id IN NUMBER);
  
  PROCEDURE INSERT_REV_REC_DETAILS(p_rev_rec IN t_rev_rec, pi_request_id IN NUMBER);

  PROCEDURE CALC_REV_AMOUNT_P(     pi_request_id 	IN NUMBER,
                                   pi_order_id   	IN NUMBER,
			           pi_line_id    	IN NUMBER,
			           pi_org_id     	IN NUMBER,
			           pi_tenant_id  	IN NUMBER,
			           pi_line_type  	IN VARCHAR2,
			           pi_unit_price 	IN NUMBER,
			           pi_quantity   	IN NUMBER,
			           pi_uom        	IN VARCHAR2,
			           pi_rev_rec_type      IN VARCHAR2,
			           pi_period_start_date IN DATE,
			           pi_period_end_date   IN DATE,
			           po_rev_amount     	OUT NUMBER,
			           po_unit_price     	OUT NUMBER,
			           po_adjustment     	OUT NUMBER,
			           po_quantity       	OUT NUMBER);

  PROCEDURE GENERATE_REV_SCHEDULE (pi_request_id IN NUMBER,
			           pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER);
			             

  PROCEDURE REV_RECOG_P           (
                                   pi_errbuf     OUT VARCHAR2,
                                   pi_retcode    OUT VARCHAR2,
                                   pi_request_id IN NUMBER,
			           pi_order_id   IN NUMBER,
			           pi_line_id    IN NUMBER,
			           pi_org_id     IN NUMBER,
			           pi_tenant_id  IN NUMBER,
			           pi_from_date  IN DATE,
			           pi_to_date    IN DATE,
			           pi_period     IN VARCHAR2);
			           
     PROCEDURE TERMINATE_CONTRACT_REV_P (
					   pi_errbuf     OUT VARCHAR2,
					   pi_retcode    OUT VARCHAR2,
					   pi_request_id IN NUMBER,
					   pi_order_id   IN NUMBER,
					   pi_line_id    IN NUMBER,
					   pi_org_id     IN NUMBER,
					   pi_tenant_id  IN NUMBER);			           
			           

END;
/
