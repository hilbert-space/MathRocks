define files
	abscissa_level_closed_nd.m
	abscissa_level_open_nd.m
	cc_abscissa.m
	cc_weights.m
	comp_next.m
	f1_abscissa.m
	f1_weights.m
	f2_abscissa.m
	f2_weights.m
	gh_abscissa.m
	gh_weights.m
	gl_abscissa.m
	gl_weights.m
	gp_abscissa.m
	gp_weights.m
	i4_log_2.m
	i4_modp.m
	index_level_own.m
	index_to_level_closed.m
	index_to_level_open.m
	level_to_order_closed.m
	level_to_order_open.m
	levels_index.m
	levels_index_cfn.m
	levels_index_ofn.m
	levels_index_onn.m
	levels_index_own.m
	levels_index_size.m
	levels_index_size_onn.m
	levels_index_size_own.m
	levels_index_size_test.m
	levels_index_test.m
	lg_abscissa.m
	lg_weights.m
	monomial_integral_hermite.m
	monomial_integral_laguerre.m
	monomial_integral_legendre.m
	monomial_quadrature.m
	monomial_value.m
	multigrid_index_cfn.m
	multigrid_index_ofn.m
	multigrid_index_onn.m
	multigrid_index_own.m
	multigrid_scale_closed.m
	multigrid_scale_open.m
	product_weights.m
	r8_choose.m
	r8_factorial.m
	r8_factorial2.m
	r8_huge.m
	r8vec_direct_product2.m
	sandia_sparse_test.m
	sparse_grid.m
	sparse_grid_cc_size.m
	sparse_grid_cfn.m
	sparse_grid_compute_test.m
	sparse_grid_monomial_test.m
	sparse_grid_ofn.m
	sparse_grid_ofn_size.m
	sparse_grid_onn.m
	sparse_grid_own.m
	sparse_grid_weight_test.m
	sparse_grid_weights_cfn.m
	sparse_grid_weights_ofn.m
	timestamp.m
	vec_colex_next2.m
endef

files := $(shell echo $(files) | tr -d '\n')

all: $(files)

$(files):
	curl http://people.sc.fsu.edu/~jburkardt/m_src/sandia_sparse/$@ -O
