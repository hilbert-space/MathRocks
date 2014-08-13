#ifndef __HOTSPOT_H__
#define __HOTSPOT_H__

extern "C" {
#include <util.h>
#include <flp.h>
#include <temperature.h>
#include <temperature_block.h>
}

#include <string>

class HotSpot
{
	protected:

	thermal_config_t config;
	flp_t *floorplan;
	RC_model_t *model;

	public:

	HotSpot(const std::string &floorplan_file, const std::string &config_file,
		const std::string &config_line);
	virtual ~HotSpot();

	inline size_t get_processor_count() const
	{
		return floorplan->n_units;
	}

	inline size_t get_node_count() const
	{
		return model->block->n_nodes;
	}

	void get_A(double *A) const;
	void get_B(double *B) const;
	void get_G(double *G) const;
	void get_G_amb(double *G_amb) const;
};

#endif
