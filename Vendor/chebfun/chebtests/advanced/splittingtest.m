function pass = splittingtest
% A collection of tests for exact jump detection
% in "splitting on" mode and singular function approximation.
% (By Rodrigo Platte)
% (A Level 1 chebtest)

tol = chebfunpref('eps');
%splitting on
debug = false;
pass = true;
try
    %for j = 1:Ntests

        % test jumps
        x0 = 0.91;
        f= chebfun(@(x) exp(x) +cos(7*x) + sign(x-x0),'splitting','on');
        pass = pass && f.ends(2) == x0 && (length(f.ends) < 4);
        if ~pass
            error('CHEBTESTS:splittingtest:j1','jump1')
        end

        x0 = -0.112;
        f= chebfun(@(x) exp(x) +cos(7*x) + sign(x-x0),'splitting','on');
        pass = pass && f.ends(2) == x0 && (length(f.ends) < 4);
        if ~pass
            error('CHEBTESTS:splittingtest:j2','jump2')
        end

        if chebfunpref('eps') > 1/1000
            f = chebfun(@(x) exp(x) +cos(7*x) + 0.1*sign(x-x0),'splitting','on')+1;
            pass = pass && f.ends(2) == x0 && (length(f.ends) < 4);
            if ~pass
                error('CHEBTESTS:splittingtest:j3','jump3')
            end
        end

        % test C0 functions
        f= chebfun(@(x) exp(x) +cos(7*x) + abs(x-x0),'splitting','on');
        pass = pass && (length(f.ends)<3) || (abs(f.ends(2) - x0)< 1e-12*(tol/eps) && (length(f.ends) < 4));
        if ~pass
            abs(f.ends(2) - x0)
            error('CHEBTESTS:splittingtest:C0','C0')
        end

        % test C1 functions
        f= chebfun(@(x) (x-x0).^2.*double(x>x0),'splitting','on');
        pass = pass && abs(f.ends(2) - x0)< 1e-8*(tol/eps) && (length(f.ends) < 4);
        if ~pass
            error('CHEBTESTS:splittingtest:C1','C1')
        end

        % test C2 functions
        f= chebfun(@(x) exp(x) + abs(x-x0).^3+1,'splitting','on');
        pass = pass && abs(f.ends(2) - x0)< 1e-4*(tol/eps) && (length(f.ends) < 4);
        if ~pass
            error('CHEBTESTS:splittingtest:C2','C2')
        end

        % test C3 functions
        f= chebfun(@(x) (x-x0).^4.*double(x>x0),'splitting','on');
        pass = pass && (length(f.ends) < 5);
        if ~pass
            error('CHEBTESTS:splittingtest:C3','C3')
        end

    %end
    
    % test sqrt
    ff = @(x) sqrt(x-2)+10;
    f = chebfun(ff, [2,20],'splitting','on');
    xx = linspace(2,10);
    pass = pass && length(f) <600 && norm(f(xx) - ff(xx),inf)<5e-7*(tol/eps);
    if ~pass
        error('CHEBTESTS:splittingtest:sqrt','SQRT')
    end

catch ME
    
    if debug
        disp('catch')
        disp(x0)
        disp(ME.message)
    end
    
end
