function F = isfinite(F)
% ISFINITE True for finite chebfuns.
%
% ISFINITE(X) operates on the continuous dimension of a chebfun X and 
% returns a chebfun which is 1 when the elements of X are finite and 
% 0's where they are not. Typically infinite values of X are only 
% permitted at breakpoints of X. 
%  
% For a complex-valued chebfun X, ISFINITE(X) returns 1 if both the
% real and imaginary parts of X are finite. For any real X, exactly one
% of ISFINITE(X), ISINF(X), or ISNAN(X) is 1 for each element.
%  
% See also ISNAN, ISINF.
    
for k = 1:numel(F)
    F(k) = isfcol(F(k));            % Loop over quasimatrix rows
end

function Fout = isfcol(F)

if ~isreal(F)
    Fout = isfcol(real(F)) & isfcol(imag(F));
    return
end

Fout = chebfun(1,F.ends([1 end]));  % Make a chebfun of ones

% % Deal with the case of infinite constant chebfuns
% zer = chebfun(0);                   
% for k = 1:F.nfuns
%    if ~isfinite(F.funs(k).vals(1))
%        Fout = define(Fout,domain(F.ends(k:k+1)),zer);
%    end
% end
% Fout.imps = ones(1,size(Fout.imps,2));

idx = ~isfinite(F.imps);                % Find infinite imps of F
Fout = define(Fout,F.ends(idx),0);  % Assign to 0 in Fout


