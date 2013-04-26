#ifndef __HOTSPOT_H__
#define __HOTSPOT_H__

extern "C" {
#include <hotspot/util.h>
#include <hotspot/flp.h>
#include <hotspot/temperature.h>
#include <hotspot/temperature_block.h>
}

#include <string>

class HotSpot
{
	protected:

	size_t node_count;
	size_t processor_count;

	double sampling_interval;
	double ambient_temperature;

	thermal_config_t config;
	flp_t *floorplan;
	RC_model_t *model;

	public:

	HotSpot(const std::string &floorplan, const std::string &config_file,
		const std::string &config_line);
	virtual ~HotSpot();

	inline size_t get_node_count() const
	{
		return node_count;
	}

	inline size_t get_processor_count() const
	{
		return processor_count;
	}

	inline double get_sampling_interval() const
	{
		return sampling_interval;
	}

	inline double get_ambient_temperature() const
	{
		return ambient_temperature;
	}

	void get_capacitance(double *capacitance) const;
	void get_conductance(double *conductance) const;
};

#endif
