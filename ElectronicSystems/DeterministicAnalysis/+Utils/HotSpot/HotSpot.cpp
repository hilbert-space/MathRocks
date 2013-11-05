#include <sstream>
#include <stdexcept>
#include <string.h>

#include "HotSpot.h"

size_t read_config_line(str_pair *table, size_t max, const std::string &line)
{
	size_t count = 0;

	std::string name, value;
	std::stringstream stream(line);

	while (true) {
		stream >> name;

		if (name.empty() || stream.eof() || stream.bad())
			throw std::runtime_error("The configuration line is invalid.");

		stream >> value;

		if (stream.bad())
			throw std::runtime_error("The configuration line is invalid.");

		strcpy(table[count].name, name.c_str());
		strcpy(table[count].value, value.c_str());

		count++;

		if (stream.eof()) break;
	}

	return count;
}

HotSpot::HotSpot(const std::string &floorplan_file,
	const std::string &config_file, const std::string &config_line)
{
	config = default_thermal_config();

	if (!config_file.empty()) {
		str_pair table[MAX_ENTRIES];
		size_t i = read_str_pairs(table, MAX_ENTRIES,
			const_cast<char *>(config_file.c_str()));
		thermal_config_add_from_strs(&config, table, i);
	}

	if (!config_line.empty()) {
		str_pair table[MAX_ENTRIES];
		size_t i = read_config_line(table, MAX_ENTRIES, config_line);
		thermal_config_add_from_strs(&config, table, i);
	}

	floorplan = read_flp(const_cast<char *>(floorplan_file.c_str()), FALSE);

	model = alloc_RC_model(&config, floorplan);

	populate_R_model(model, floorplan);
	populate_C_model(model, floorplan);
}

HotSpot::~HotSpot()
{
	delete_RC_model(model);
	free_flp(floorplan, FALSE);
}

void HotSpot::get_A(double *A) const
{
	const double *a = model->block->a;

	size_t count = get_node_count();
	for (size_t i = 0; i < count; i++)
		A[i] = a[i];
}

void HotSpot::get_B(double *B) const
{
	double const * const * const b = model->block->b;

	size_t count = get_node_count();
	for (size_t i = 0; i < count; i++)
		for (size_t j = 0; j < count; j++)
			B[i * count + j] = b[i][j];
}

void HotSpot::get_G(double *G) const
{
	double const * const * const g = model->block->g;

	size_t count = get_node_count();
	for (size_t i = 0; i < count; i++)
		for (size_t j = 0; j < count; j++)
			G[i * count + j] = g[i][j];
}

void HotSpot::get_G_amb(double *G_amb) const
{
	const double *g_amb = model->block->g_amb;

	size_t count = get_processor_count() + EXTRA;
	for (size_t i = 0; i < count; i++)
		G_amb[i] = g_amb[i];
}
