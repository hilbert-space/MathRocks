include ../common.mk

define filenames
	sgmga_aniso_balance.m
	sgmga_aniso_balance_test.m
	sgmga_aniso_balance_tests.m
	sgmga_aniso_normalize.m
	sgmga_aniso_normalize_test.m
	sgmga_aniso_normalize_tests.m
	sgmga_importance_to_aniso.m
	sgmga_importance_to_aniso_test.m
	sgmga_importance_to_aniso_tests.m
	sgmga_index.m
	sgmga_index_test.m
	sgmga_index_tests.m
	sgmga_point.m
	sgmga_point_test.m
	sgmga_point_tests.m
	sgmga_product_weight.m
	sgmga_product_weight_test.m
	sgmga_product_weight_tests.m
	sgmga_size.m
	sgmga_size_table.m
	sgmga_size_tabulate.m
	sgmga_size_test.m
	sgmga_size_tests.m
	sgmga_size_total.m
	sgmga_unique_index.m
	sgmga_unique_index_test.m
	sgmga_unique_index_tests.m
	sgmga_vcn.m
	sgmga_vcn_coef.m
	sgmga_vcn_coef_naive.m
	sgmga_vcn_coef_test.m
	sgmga_vcn_coef_tests.m
	sgmga_vcn_naive.m
	sgmga_vcn_ordered.m
	sgmga_vcn_ordered_naive.m
	sgmga_vcn_ordered_test.m
	sgmga_vcn_ordered_tests.m
	sgmga_vcn_test.m
	sgmga_vcn_tests.m
	sgmga_vcn_timing_test.m
	sgmga_vcn_timing_tests.m
	sgmga_weight.m
	sgmga_weight_test.m
	sgmga_weight_tests.m
	sgmga_write.m
	sgmga_write_test.m
	sgmga_write_tests.m
endef

url := http://people.sc.fsu.edu/~jburkardt/m_src/sgmga
filenames := $(shell echo $(filenames) | tr -d '\n')

all: $(filenames)

$(filenames):
	curl $(url)/$@ -O
