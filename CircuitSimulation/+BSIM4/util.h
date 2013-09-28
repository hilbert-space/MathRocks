#ifndef __UTIL_H__
#define __UTIL_H__

#define MAX(X, Y) ((X) > (Y) ? (X) : (Y))

int BSIM4PAeffGeo(
	double nf,
	int geo,
	int minSD,
	double Weffcj,
	double DMCG,
	double DMCI,
	double DMDG,
	double *Ps,
	double *Pd,
	double *As,
	double *Ad);

int BSIM4RdsEndIso(
	double Weffcj,
	double Rsh,
	double DMCG,
	double DMCI,
	double DMDG,
	double nuEnd,
	int rgeo,
	int Type,
	double *Rend);

int BSIM4RdsEndSha(
	double Weffcj,
	double Rsh,
	double DMCG,
	double DMCI,
	double DMDG,
	double nuEnd,
	int rgeo,
	int Type,
	double *Rend);

#endif
