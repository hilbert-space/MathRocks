#ifndef __MEX_UTILS_H__
#define __MEX_UTILS_H__

#include <string>
#include <mex.h>

void from_matlab(double *dest, const double *src, size_t rows, size_t cols)
{
	for (size_t i = 0; i < rows; i++)
		for (size_t j = 0; j < cols; j++)
			dest[i * cols + j] = src[i + j * rows];
}

void to_matlab(double *dest, const double *src, size_t rows, size_t cols)
{
	for (size_t i = 0; i < rows; i++)
		for (size_t j = 0; j < cols; j++)
			dest[i + j * rows] = src[i * cols + j];
}

void cross_matlab(double *dest_src, size_t rows, size_t cols)
{
	for (size_t i = 0; i < rows; i++)
		for (size_t j = 0; j < cols; j++) {
			double temp = dest_src[i + j * rows];
			dest_src[i + j * rows] = dest_src[i * cols + j];
			dest_src[i * cols + j] = temp;
		}
}

template<class T>
T from_matlab(const mxArray *array)
{
	if (!array) mexErrMsgTxt("The value is not given.");
	return (T)mxGetScalar(array);
}

template<>
std::string from_matlab(const mxArray *array)
{
	if (!array) mexErrMsgTxt("The value is not given.");

	char *pointer = mxArrayToString(array);
	if (!pointer) mexErrMsgTxt("Cannot read the string.");

	std::string line(pointer);

	mxFree(pointer);

	return line;
}

template<class T>
mxArray *to_matlab(const T scalar)
{
	mxArray *out = mxCreateDoubleMatrix(1, 1, mxREAL);
	double *_out = mxGetPr(out);
	*_out = (double)scalar;

	return out;
}

#endif
