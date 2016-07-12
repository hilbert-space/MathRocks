#include <mex.h>
#include <stdio.h>
#include <openssl/md5.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	char line[2 * MD5_DIGEST_LENGTH + 1];
	unsigned char hash[MD5_DIGEST_LENGTH];

	if (nrhs != 1)
		mexErrMsgTxt("One and only one input argument is required.");

	MD5((const unsigned char *)mxGetPr(prhs[0]),
		mxGetElementSize(prhs[0]) * mxGetNumberOfElements(prhs[0]), hash);

	for (size_t i = 0; i < MD5_DIGEST_LENGTH; i++)
		sprintf(line + 2 * i, "%02x", hash[i]);
	line[2 * MD5_DIGEST_LENGTH] = '\0';

	plhs[0] = mxCreateString(line);
}
