sympoly: Symbolic polynomials
Copyright 2009-2011 Levente Hunyadi

A polynomial is a mathematical expression involving a sum of powers in one or more variables multiplied by coefficients. A general multivariate polynomial is captured with the syntax

p = sum( c_i * prod( x_j^p_ij ) ) + k

where the summation is over i, the product over j, and c_i is the set of polynomial term coefficients, x_ij is a set of symbolic variables, p_ij is the (usually positive integer) exponent of each variable in a term where at least one p_ij is nonzero for a given i, and k is the constant term.

sympoly supports regular elementwise and matrix operations like addition, subtraction, multiplication, power and division; transpose and diagonalization; indefinite and definite integration and differentiation w.r.t. a variable; gradient; coefficient extraction; conversion from and to a Symbolic Toolbox sym object and a numeric array; pretty-printing (overloaded disp and display functions); LaTeX and MatLab code generation (a character string that can be passed to eval). In order to get a list of operations supported on a sympoly object, type "methods sympoly" at the command prompt.

EXAMPLES

% create sympoly objects
x = sympoly('x')
sympolys y z

% combine sympoly objects in arbitrary expressions
q = (x-1)^3 + x*y*z - (x+1)*(z-1)

% differentiate a sympoly w.r.t. a variable
diff(q, x)

% create a matrix of symbolic polynomials and take sum of rows
sum([ x x+2 ; y+1 z ], 2)

% create symbolic polynomials with variables other than strings
y0 = sympoly(symvard('y',0));
y1 = sympoly(symvard('y',-1));
y2 = sympoly(symvard('y',-2));
u1 = sympoly(symvard('u',-1));

% create a system equation for a polynomial dynamic system
phi = [y0;y1;y2;u1;u1^2;y1*y2;u1*y1]
theta = [-1;1.5;-0.7;1;-0.3;-0.05;0.1]
G = phi'*theta

Further examples are included in the subfolder "demo" in the distribution, reproduced with minor changes from the "Symbolic Polynomial Manipulation" package by John D'Errico.

IMPLEMENTATION

From an implementation point of view, a scalar sympoly object is a class with read-only properties ConstantValue, Variables, Coefficients and Exponents, where ConstantValue is a numeric scalar, Variables is a 1-by-n row cell vector of strings or a row vector of (subclasses of) symvariable objects, Coefficients is an m-by-1 numeric column vector of polynomial term coefficients, and Exponents is an m-by-n numeric matrix of exponents for each variable in each term. The items in Variables are always sorted in a standard order, e.g. when variables are strings, they are sorted alphabetically. Since sympoly is a new-style class declared with the classdef keyword, you can use inheritance to derive custom classes from sympoly.

Most methods of the class sympoly are implemented such that they handle both scalar and array inputs. When invoked on array input, these operations either return a scalar result that applies over all elements, or a result array of the same dimensions as the input array where each element in the result corresponds to an element in the input.

COMPARISON

In contrast to MatLab's built-in roots function, which deals with univariate polynomials, sympoly can handle polynomials of multiple variables. Since it is restricted to the class of polynomials, it offers better performance and more flexibility than a sym object in the Symbolic Toolbox. sympoly is an extended version of the "Symbolic Polynomial Manipulation" package by John D'Errico using new-style MatLab classes with slight differences in implementation and function signatures.

REFERENCES

John D'Errico, "Symbolic Polynomial Manipulation", MatLab Central File Exchange, http://www.mathworks.com/matlabcentral/fileexchange/9577

CONTACT INFORMATION

Levente Hunyadi
http://hunyadi.info.hu/

Please use my private e-mail address to submit bug reports, which will be addressed upon short notice; reviews, however, are not monitored. Any feedback is most welcome.