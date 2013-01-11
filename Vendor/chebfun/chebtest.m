function varargout = chebtest(dirname)
%CHEBTEST Probe Chebfun against standard test files.
% CHEBTEST DIRNAME runs each M-file in the directory DIRNAME. Each M-file
% should be a function that takes no inputs and returns a logical scalar
% value. If this value is true, the function is deemed to have 'passed'. 
% If its result is false, the function 'failed'. If the function threw an
% error, it is considered to have 'crashed'. A report is generated in the
% command window, and in a file 'chebtestreport' in the chebfun directory.
%
% CHEBTEST by itself tries to find a directory named 'chebtests' in the
% directory in which chebtest.m resides.
%
% FAILED = CHEBTEST returns a cell array of all functions that either 
% failed or crashed. A report is also generated in the file
%   <chebfun_directory>/chebtests/chebtest_report.txt
%
% CHEBTEST RESTORE restores user preferences prior to CHEBTEST execution.
% CHEBTEST modifies path, warning state, and chebfunpref during execution.
% If a CHEBTEST execution is interrupted, the RESTORE option can be used to
% reset these values. 
%
% Chebtest looks first for the subdirectories below, and executes the tests
% therein in alphabetical order. The tests should be assigned to different
% directories according to the following scheme:
%
%   basic:    Tests of the basic Chebfun routines such as arithmetic
%             operators, constructors, preferences, etc...
%   advanced: Tests for more complex operations of a single chebfun, e.g.
%             norm, max, roots, diff, sum, etc...
%   quasimatrices: Tests involving systems of chebfuns (quasimatrices).
%   linops:   Tests involving linear operators (linops).
%   chebop:   Tests involving non-linear chebops (chebops)
%   ad:       Tests involving automatic differentiation (AD).
%   misc:     Tests that don't fit elsewhere (BVP and IVP solvers, etc).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

persistent userpref

if nargin == 1 && ischar(dirname) && strcmpi(dirname,'restore')
    if isempty(userpref)
%         disp('First execution of chebtests (or information has been cleared), preferences unchanged.')
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
pref = chebfunpref;
tol = pref.eps;
createreport = true;
avgtimes = false; % If turning off, remember to remove line from help comments.
nr_tests = 0;
tests = struct('fun','','path','','funptr',[]);

if verLessThan('matlab','7.6')
    matlabver = ver('matlab');
    disp(['MATLAB version: ',matlabver.Version, ' ', matlabver.Release])
    error('CHEBFUN:chebtest:version',['Chebfun is compatible' ...
        ' with MATLAB 7.6 (R2008a) or above.'])
end

% Chebfun directory
chbfundir = fileparts(which('chebtest.m'));

if nargin < 1
    % Attempt to find "chebtests" directory.
    dirname = fullfile(chbfundir,'chebtests');
end

% Deal with levelX input
if ischar(dirname)
    if ~isempty(str2num(dirname))
        dirname = str2num(dirname);
    elseif strncmpi(dirname,'level',5)
        dirname = fullfile(chbfundir,'chebtests',lower(dirname));
    end
end

if ~exist(dirname,'dir')
    tmpdirname = fullfile(chbfundir,'chebtests',dirname);
    if ~exist(tmpdirname,'dir')
          msg = ['The name "' dirname '" does not appear to be a directory on the path.'];
          error('CHEBFUN:chebtest:nodir',msg)
    else
        dirname = tmpdirname;
    end
end


% Store user preferences for warning and chebfunpref
warnstate = warning;
userpref.warnstate = warnstate;
userpref.path = path;
userpref.pref = pref;
userpref.oppref = cheboppref;
userpref.dirname = dirname;

% Add chebtests directory to the path
addpath(dirname)

% Get the chebtest directory names
subdirlist = dir( fullfile(dirname) );
subdirnames = { subdirlist.name };
numdirs = length(subdirnames);

% Assign an order
defaultOrder = {'basic','advanced','quasimatrices','linops','chebops','ad','misc'};
order = 1:numdirs;
for i = 1:numdirs
    idx = find(strcmp(subdirnames(i),defaultOrder));
    if ~isempty(idx)
        order(order == idx) = order(i);
        order(i) = idx;
    end
end
% Order is stored in inverse format. Flip.
[ignored order] = sort(order);

% loop over the level directories (first)
for i=order

    % is this really a directory?
    if ~subdirlist(i).isdir, continue; end;
    if any(strcmp(subdirnames(i),{,'.','..'})), continue; end;
    
    % add it to the path
    addpath( fullfile(dirname,subdirnames{i}) );

    % Get the names of the tests for this level
    dirlist = dir(fullfile(dirname,subdirnames{i},'*.m'));
    for j=1:length(dirlist)
        nr_tests = nr_tests + 1;
        tests(nr_tests).fun = dirlist(j).name(1:end-2);
        tests(nr_tests).path = [ dirname filesep subdirnames{i} filesep dirlist(j).name ];
        tests(nr_tests).funptr = str2func( dirlist(j).name(1:end-2) );
    end;
    
    % remove the path
    rmpath( fullfile(dirname,subdirnames{i}) )
    
end

% Get the names of any un-sorted tests
dirlist = dir( fullfile(dirname,'*.m') );
for j=1:length(dirlist)
    nr_tests = nr_tests + 1;
    tests(nr_tests).fun = dirlist(j).name(1:end-2);
    tests(nr_tests).path = [ dirname filesep dirlist(j).name ];
    tests(nr_tests).funptr = str2func( dirlist(j).name(1:end-2) );
end

% restore the original path names
path( userpref.path );

% check for duplicate chebtest names
um = unique( { tests(:).fun } , 'first' );
if numel(um) < nr_tests
    warning('CHEBFUN:chebtest:unique','Nonunique chebtest names detected.');
end

% Find the length of the names (for pretty display later).
namelen = 0;
for k = 1:nr_tests
    namelen = max(namelen,length(tests(k).fun));
end
    
% Initialise some storage
failed = zeros(nr_tests,1);  % Pass/fail
t = failed;                        % Vector to store times

% Clear the report file (and check we can open file)
report = fullfile(chbfundir,'chebtests','chebtest_report.txt');
[fid message] = fopen(report,'w+');
if fid < 0
    warning('CHEBFUN:chebtest:fopenfail', ...
        ['Cannot create chebtest report: ', message]);
    createreport = false;
    avgtimes = false;
else
    fclose(fid);
end

% For looking at average time performance.
if avgtimes
    avgfile = fullfile(chbfundir,'chebtests','chebtest_avgs.txt');
    if ~exist(avgfile,'file')
        fclose(fopen(avgfile,'w+'));
    end
    avgfid = fopen(avgfile,'r');    
    avgt = fscanf(avgfid,'%f',inf);
    fclose(avgfid);
    if length(t) ~= length(avgt)-1
        % Number of chebtests has changed, so scrap averages.
        fclose(fopen(avgfile,'w+'));
        avgt = 0*t;
    end
    avgN = avgt(end);
    avgTot = sum(avgt(1:end-1));
else
    avgN = 0; avgt = 0*t;
end

% If java is not enabled, don't display html links.
javacheck = true;
if ~usejava('jvm') || ~usejava('desktop')
    javacheck = false;
end

prevdir = 'bogus';

% Turn off warnings for the test
warning off

% loop through the tests
for j = 1:nr_tests
  fun = tests(j).fun;
  % Print the test directory (if new)
  whichfun = tests(j).path;
  fparts = fileparts(whichfun);
  curdir = fparts(find(fparts==filesep,1,'last')+1:end);
  if ~strcmp(curdir,prevdir)
      prevdir = curdir;
      fprintf('%s tests:\n',curdir);
  end
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
  % Execute the test
  try
    close all
    chebfunpref('factory');
    cheboppref('factory');
    chebfunpref('eps',tol);
    tic
    pass = feval( tests(j).funptr );
    t(j) = toc;
    failed(j) = ~ all(pass);
    if failed(j)
      fprintf('FAILED\n')
      
      % Create an error report entry for a failure
      if createreport
        fid = fopen(report,'a');
        fprintf(fid,[fun '  (failed) \n']);
        fprintf(fid,['pass: ''' int2str(pass) '''\n\n']);
        fclose(fid);
      end

    else
        avgt(j) = (avgN*avgt(j)+t(j))/(avgN+1);
        if avgN == 0
          fprintf('passed in %2.3fs \n',t(j))
        else
          fprintf('passed in %2.3fs (avg %2.3fs)\n',t(j),avgt(j))
        end
      %pause(0.1)
      %fprintf( repmat('\b',1,numchar) )
    end
  catch ME
    failed(j) = -1;
    fprintf('CRASHED: ')
    msg = ME;
    lf = findstr(sprintf('\n'),msg.message); 
    if ~isempty(lf), msg.message(1:lf(end))=[]; end
    fprintf([msg.message '\n'])
   
    % Create an error report entry for a crash
    if createreport
        fid = fopen(report,'a');
        fprintf(fid,[fun '  (crashed) \n']);
        fprintf(fid,['identifier: ''' msg.identifier '''\n']);
        fprintf(fid,['message: ''' msg.message '''\n']);
        for k = 1:size(msg.stack,1)
            fprintf(fid,[msg.stack(k).file ' \tline ' int2str(msg.stack(k).line) '\n']);
        end
    fprintf(fid,'\n');
    fclose(fid);
    end

  end
  
end
warning(warnstate)
chebfunpref(pref);
cheboppref(userpref.oppref);

% Final output
ts = sum(t); tm = ts/60;
if avgN == 0
    fprintf('Total time: %1.1f seconds = %1.1f minutes \n',ts,tm)
else
    fprintf('Total time: %1.1f seconds (Lifetime Avg: %1.1f seconds)\n',ts,avgTot)
end

if all(~failed)
  fprintf('\nAll tests passed!\n')
  failfun = [];
else
  fprintf('\n%i failed and %i crashed\n',sum(failed>0),sum(failed<0))
  failfun = tests(failed~=0);
  if createreport
      if javacheck
          link = ['<a href="matlab: edit ''' report '''">chebtest_report.txt</a>'];
      else
          link = report;
      end
      msg = [' Error report available here: ' link '. ' ];
      msg = strrep(msg,'\','\\');  % escape \ for fprintf
      numchar = fprintf(msg); fprintf('\n')
  end
end

% Update average times (if enabled and no failures)
if avgtimes && all(~failed)
    avgfid = fopen(avgfile,'w+');    
    for k = 1:size(t,1)
        fprintf(avgfid,'%f\n',avgt(k));
    end
    fprintf(avgfid,'%d \n',avgN+1);
    fclose(avgfid);
end

% Output args
if nargout > 0
    if isempty(failfun)
        varargout{1} = [];
    else
        varargout{1} = { failfun(:).fun }; 
    end
else
    fprintf('    ');
    for k = 1:sum(abs(failed))
        fun = failfun(k).fun;
        whichfun = failfun(k).path;
        if javacheck         
            link = ['<a href="matlab: edit ''' whichfun '''">' fun '</a>    '];
            link = strrep(link,'\','\\');  % maintain fprintf compatability in MSwin
        else
            link = fun;
        end
        fprintf([ link '    ' ])
    end
    fprintf('\n');
end
if nargout > 0, varargout{2} = t; end

if createreport && any(failed)
    fid = fopen(report,'a');

    % GET SYSTEM INFORMATION
    % find platform OS
    if ispc
        platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
    elseif ismac
        [fail, input] = unix('sw_vers');
        if ~fail
            platform = strrep(input, 'ProductName:', '');
            platform = strrep(platform, sprintf('\t'), '');
            platform = strrep(platform, sprintf('\n'), ' ');
            platform = strrep(platform, 'ProductVersion:', ' Version: ');
            platform = strrep(platform, 'BuildVersion:', 'Build: ');
        else
            platform = system_dependent('getos');
        end
    else    
        platform = system_dependent('getos');
    end
    % display platform type
    fprintf(fid,['MATLAB Version ',version,'\n']);
    % display operating system
    fprintf(fid,['Operating System: ',  platform,'\n']);
    % display first line of Java VM version info
    fprintf(fid,['Java VM Version: ',...
    char(strread(version('-java'),'%s',1,'delimiter','\n'))]);

    fclose(fid);
elseif createreport && ~any(failed)
    delete(report);
end
