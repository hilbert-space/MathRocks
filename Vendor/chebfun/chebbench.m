function varargout = chebbench(varargin)
%CHEBBENCH  Chebfun Benchmark
% CHEBBENCH times a small number of core chebfun operations for
% benchmarking code changes. The mfiles used for benchmarking are stored in
% the $chebfun/chebench/ directory. It is possible to add new tests, and
% each test should be looped internally so as to take around a second to
% run.
% 
% CHEBBENCH runs each test once.
% CHEBBENCH(N) runs each test N times.
% T = CHEBBENCH(N) returns an <no.-of-tests>-by-N array of execution times.
%
% CHEBBENCH('save',FILENAME) saves the results of the bench test to the 
% text file FILENAME. CHEBBENCH('load',FILENAME) will load an existing
% bench report for comparison with the current benchmarking, where the
% third column displayed is the difference in current versus loaded time.
% By default CHEBBENCH saves the latest test to
%       $chebfun/chebbench/chebbench_retport.txt
% and this can be loaded with CHEBBENCH('load','default').
%
% CHEBBENCH('restore') restores user preferences prior to chebtest
% execution. CHEBBENCH modifies path, warning state, and chebfunpref during
% execution. If a CHEBBENCH execution is interrupted, the 'restore' option
% can be used to reset these values.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

persistent userpref

if nargin >0 && strcmpi(varargin{1},'restore')
    if isempty(userpref)
        return
    end
    warning(userpref.warnstate)
    rmpath(userpref.dirname)
    path(path,userpref.path)
    chebfunpref(userpref.pref);
    cheboppref(userpref.oppref);
    disp('Restored values of warning, path, and chebfunpref.')
    return
end

% init some local data
N = 1; % By default, run each test once.
pref = chebfunpref;
tol = pref.eps;
savereport = true;
comparereport = false;
nr_tests = 0;
nr_tests2 = 0;
tests = struct('fun','','path','','funptr',[]);

% Chebfun directory
chbfundir = fileparts(which('chebtest.m'));
% Attempt to find "chebtests" directory.
dirname = fullfile(chbfundir,'chebbench');

% Store user preferences for warning and chebfunpref
warnstate = warning;
userpref.warnstate = warnstate;
userpref.path = path;
userpref.pref = pref;
userpref.oppref = cheboppref;
userpref.dirname = dirname;

% Add bench directory to the path
addpath(dirname)

% Get the names of all tests
dirlist = dir( fullfile(dirname,'*.m') );
for j=1:length(dirlist)
    nr_tests = nr_tests + 1;
    tests(nr_tests).fun = dirlist(j).name(1:end-2);
    tests(nr_tests).path = [ dirname filesep dirlist(j).name ];
    tests(nr_tests).funptr = str2func( dirlist(j).name(1:end-2) );
end

% Clear the report file (and check we can open file)
idx = strcmp(varargin,'save');
if any(idx)
    idx = find(idx);
    newreport = varargin{idx+1};
    varargin([idx idx+1]) = [];
    savereport = 1;
else
    newreport = fullfile(chbfundir,'chebbench','chebbench_report.txt');
end
if savereport
    [fid message] = fopen(newreport,'a+');
    if fid < 0
        warning('CHEBFUN:chebbench:fopenfail', ...
            ['Cannot save chebbench report: ', message]);
        savereport = false;
    end
    fclose(fid);
end

% See if we're loading a file & get the names of tests we're comparing too.
idx = strcmp(varargin,'load');
if any(idx)
    idx = find(idx);
    oldreport = varargin{idx+1};
    varargin([idx idx+1]) = [];
    if strcmp(oldreport,'default')
        oldreport = fullfile(chbfundir,'chebbench','chebbench_report.txt');
    end
    comparereport = true;
end
if comparereport
    [fid2 message] = fopen(oldreport,'r');
    if fid2 < 0
        warning('CHEBFUN:chebbench:fopenfail2', ...
            ['Cannot load chebbench report: ', message]);
        comparereport = false;
    else
        tests2 = struct('fun','','time',NaN);
        inputEnded = 0; nr_tests2 = 0;
        while ~inputEnded
            tline = fgetl(fid2);
            if tline < 0
                if nr_tests2 == 0, comparereport = false; end
                break
            end
            nr_tests2 = nr_tests2 + 1;
            idx = strfind(tline,' ');
            tests2(nr_tests2).fun = tline(1:idx(1)-1);
            tests2(nr_tests2).time = str2num(tline(idx(1)+1:end));
            inputEnded = feof(fid2);
        end
    end
    fclose(fid2);
end

if ~isempty(varargin)
    N = varargin{1};
end

% restore the original path names
path( userpref.path );

% check for duplicate test names
um = unique( { tests(:).fun } , 'first' );
if numel(um) < nr_tests
    warning('CHEBFUN:chebbench:unique','Nonunique chebtest names detected.');
end

% Find the length of the names (for pretty display later).
namelen = 0;
for k = 1:nr_tests
    namelen = max(namelen,length(tests(k).fun));
end

% Initialise some storage
t = zeros(nr_tests,N);  % Vector to store times
failed = zeros(nr_tests,1);  % For storing crashes
t2 = 0;

% If java is not enabled, don't display html links.
javacheck = true;
if ~usejava('jvm') || ~usejava('desktop')
    javacheck = false;
end

% Turn off warnings for the test
warning off

% loop through the tests
for j = 1:nr_tests
  fun = tests(j).fun;
  whichfun = tests(j).path;
  % Print the test name
  if javacheck
      link = ['<a href="matlab: edit ''' whichfun '''">' fun '</a>'];
  else
      link = fun;
  end
  ws = repmat(' ',1,namelen+3-length(fun)-length(num2str(j)));
  msg = ['  Function #' num2str(j) ' (' link ')... ', ws ];
  msg = strrep(msg,'\','\\');  % escape \ for fprintf
  numchar = fprintf(msg);
  % Reset to defaults
  close all
  chebfunpref('factory');
  cheboppref('factory');
  chebfunpref('eps',tol);
  % Execute the test
  try
      for k = 1:N
        tic
        feval( tests(j).funptr );
        t(j,k) = toc;
      end
    fprintf(' %2.3fs',sum(t(j,:)))
  catch
    failed(j) = -1;
    t(j,:) = 0;
    fprintf('CRASHED')
  end
  
  % Bail if crashed
  if failed(j) || ~comparereport
      fprintf('\n')
      continue
  end
  
  % Compare to loaded file 
  for k = 1:nr_tests2
      if strcmp(fun, tests2(k).fun)
          told = tests2(k).time;
          t2 = t2 + told;
          tdiff = sum(t(j,:)) - told;
          if tdiff > 0, pm = '+'; else pm = ''; end
          fprintf('    %2.3fs    %s%2.3fs\n', told, pm, tdiff)
          break
      end
  end 

end
warning(warnstate)
chebfunpref(pref);
cheboppref(userpref.oppref);

% Final output
ts = sum(sum(t));
ws = repmat(' ',1,namelen+8);
fprintf('\n  Total time: %s %2.3fs',ws, ts)
if comparereport
    tdiff = ts - t2;
    if tdiff > 0, pm = '+'; else pm = ''; end
    fprintf('    %2.3fs    %s%2.3fs\n', t2, pm, tdiff)
else
    fprintf('\n')
end

if any(failed)
  fprintf('\n(%i tests crashed!)\n',sum(failed<0))
end

if savereport
  fid = fopen(newreport,'w+');
  for j = 1:nr_tests
      fprintf(fid,'%s %2.4f\n',tests(j).fun,sum(t(j,:)));
  end
  fclose(fid);
    
  if javacheck
      link = ['<a href="matlab: edit ''' newreport '''">chebbench_report.txt</a>'];
  else
      link = report;
  end
  msg = [' Bench report available here: ' link '. ' ];
  msg = strrep(msg,'\','\\');  % escape \ for fprintf
  numchar = fprintf(msg); fprintf('\n')
end

if nargout > 0
    varargout{1} = t;
end


