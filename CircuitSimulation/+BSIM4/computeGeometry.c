#include <mex.h>
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 7)
		mexErrMsgIdAndTxt("BSIM4:computeGeometry:nrhs",
			"Seven input argumets are required: "
			"nf, geo, minSD, Weffcj, DMCG, DMCI, and DMDG.");

	mxArray *Ps = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray *Pd = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray *As = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray *Ad = mxCreateDoubleMatrix(1, 1, mxREAL);

	double *_Ps = mxGetPr(Ps);
	double *_Pd = mxGetPr(Pd);
	double *_As = mxGetPr(As);
	double *_Ad = mxGetPr(Ad);

	(void)BSIM4PAeffGeo(
		mxGetScalar(prhs[0]), // nf
		mxGetScalar(prhs[1]), // geo
		mxGetScalar(prhs[2]), // minSD
		mxGetScalar(prhs[3]), // Weffcj
		mxGetScalar(prhs[4]), // DMCG
		mxGetScalar(prhs[5]), // DMCI
		mxGetScalar(prhs[6]), // DMDG
		_Ps, _Pd, _As, _Ad);

	plhs[0] = Ps;
	plhs[1] = Pd;
	plhs[2] = As;
	plhs[3] = Ad;
}
