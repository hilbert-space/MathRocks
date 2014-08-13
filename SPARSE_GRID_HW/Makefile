define files
	cc.m
	cce.m
	cce_order.m
	cce_sparse_test.m
	cce_test.m
	ccl.m
	ccl_order.m
	ccl_sparse_test.m
	ccl_test.m
	ccs.m
	ccs_order.m
	ccs_sparse_test.m
	ccs_test.m
	fn_integral.m
	fn_value.m
	fu_integral.m
	fu_value.m
	get_seq.m
	get_seq_test.m
	gqn.m
	gqn2_order.m
	gqn2_sparse_test.m
	gqn_order.m
	gqn_sparse_test.m
	gqn_test.m
	gqu.m
	gqu_order.m
	gqu_sparse_test.m
	gqu_test.m
	i4_factorial2.m
	i4vec_print.m
	kpn.m
	kpn_order.m
	kpn_sparse_test.m
	kpn_test.m
	kpu.m
	kpu_order.m
	kpu_sparse_test.m
	kpu_test.m
	nwspgr.m
	nwspgr_size.m
	nwspgr_size_test.m
	nwspgr_test.m
	order_report.m
	quad_rule_print.m
	rule_adjust.m
	sparse_grid_hw_test.m
	symmetric_sparse_size.m
	symmetric_sparse_size_test.m
	tensor_product.m
	tensor_product_test.m
	timestamp.m
endef

files := $(shell echo $(files) | tr -d '\n')

all: $(files)

$(files):
	curl http://people.sc.fsu.edu/~jburkardt/m_src/sparse_grid_hw/$@ -O
