#include <mex_utils.h>
#include <HotSpot.h>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	string floorplan = from_matlab<string>(prhs[0]);
	string config_file = from_matlab<string>(prhs[1]);
	string config_line = from_matlab<string>(prhs[2]);

	HotSpot hotspot(floorplan, config_file, config_line);

	size_t node_count = hotspot.get_node_count();

	mxArray *capacitance = mxCreateDoubleMatrix(node_count, 1, mxREAL);
	mxArray *conductance = mxCreateDoubleMatrix(node_count, node_count, mxREAL);

	double *_capacitance = mxGetPr(capacitance);
	double *_conductance = mxGetPr(conductance);

	hotspot.get_capacitance(_capacitance);
	hotspot.get_conductance(_conductance);

	cross_matlab(_conductance, node_count, node_count);

	plhs[0] = capacitance;
	plhs[1] = conductance;
	plhs[2] = to_matlab<double>(hotspot.get_node_count());
	plhs[3] = to_matlab<double>(hotspot.get_processor_count());
	plhs[4] = to_matlab<double>(hotspot.get_sampling_interval());
	plhs[5] = to_matlab<double>(hotspot.get_ambient_temperature());
}
