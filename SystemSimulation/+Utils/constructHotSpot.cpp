#include <mex_utils.h>
#include <HotSpot.h>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	string floorplan_file = from_matlab<string>(prhs[0]);
	string config_file = from_matlab<string>(prhs[1]);
	string config_line = from_matlab<string>(prhs[2]);

	HotSpot hotspot(floorplan_file, config_file, config_line);

	size_t processor_count = hotspot.get_processor_count();
	size_t node_count = hotspot.get_node_count();

	mxArray *A = mxCreateDoubleMatrix(node_count, 1, mxREAL);
	mxArray *B = mxCreateDoubleMatrix(node_count, node_count, mxREAL);
	mxArray *G = mxCreateDoubleMatrix(node_count, node_count, mxREAL);
	mxArray *G_amb = mxCreateDoubleMatrix(processor_count + EXTRA, 1, mxREAL);

	double *_A = mxGetPr(A);
	double *_B = mxGetPr(B);
	double *_G = mxGetPr(G);
	double *_G_amb = mxGetPr(G_amb);

	hotspot.get_A(_A);
	hotspot.get_B(_B);
	hotspot.get_G(_G);
	hotspot.get_G_amb(_G_amb);

	cross_matlab(_B, node_count, node_count);
	cross_matlab(_G, node_count, node_count);

	plhs[0] = A;
	plhs[1] = B;
	plhs[2] = G;
	plhs[3] = G_amb;
}
