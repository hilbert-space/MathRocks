function make_examples(dirs,filename)
%MAKE_EXAMPLES  Publish the files in the examples directory.
% MAKE_EXAMPLES(DIR) published only the files in $Chebfunroot/examples/DIR,
% where DIR may be a string or a cell array of strings.
%
% MAKE_EXAMPLES(DIR,FILE) will only publish the file FILENAME.M in directory 
% $Chebfunroot/examples/DIR/ where FILENAME and DIR must be strings.

% The flags below can only be adjusted manually.
html = true;  % Publish to html? (This should be true when released).
pdf = true;   % By default this will be off.
shtml = true; % This should only be used by admin for creating the 
              % shtml files for the Chebfun website.
clean = false;
listing = false;
exampleshtml = false;
release = false;

if nargin > 0 && ischar(dirs) 
    if strncmp(dirs,'listing',4); listing = true; end
    if strcmp(dirs,'clean'); clean = true; end
    if strcmp(dirs,'html'); 
        exampleshtml = true; 
        shtml = false;
        html = true;
        pdf = false;
        listing = false;
    end
    if strcmp(dirs,'release'); 
        release = true;
        exampleshtml = false; 
        shtml = false;
        html = true;
        pdf = false;
        listing = false;
    end
end

webdir = '/common/htdocs/www/maintainers/hale/chebfun/';
examplesdir = pwd;
% Define formatting.
% HTML formatting
opts = [];
opts.stylesheet = fullfile(examplesdir,'templates','custom_mxdom2simplehtml.xsl');
if ~shtml || ~exist(opts.stylesheet,'file'), 
    opts.stylesheet = [];   % Resort to default stylesheet.
end       
opts.catchError = false;
% opts.evalCode = false;

% PDF formatting
optsPDF = [];
optsPDF.stylesheet = fullfile(examplesdir,'templates','custom_mxdom2latex.xsl'); 
% optsPDF.format = 'pdf'; 
optsPDF.format = 'latex'; 
if ~shtml || ~exist(optsPDF.stylesheet,'file') || strcmp(optsPDF.format,'pdf'), 
    optsPDF.stylesheet = [];   % Resort to default stylesheet.
end 
optsPDF.outputDir = 'pdf'; 
optsPDF.catchError = false;

% These exampels are special because they produce output from the
% anon/display field, which, because java is running will attempt to pipe
% hyperlinks to the command window. This results in a massive mess, which
% we clean up by filtering the html and tex files.
javalist = {'ChebfunAD'};

if nargin == 0 || listing || clean || exampleshtml || release
    % Find all the directories (except some exclusions).
    dirlist = struct2cell(dir(fullfile(pwd)));
    dirs = {}; k = 1;
    for j = 3:size(dirlist,2)
        if dirlist{4,j} && ...
                ~strncmp(dirlist{1,j},'.',1) && ...
                ~strcmp(dirlist{1,j},'templates') && ...
                ~strcmp(dirlist{1,j},'old_examples') && ...
                ~strcmp(dirlist{1,j},'old') && ...
                ~strcmp(dirlist{1,j},'temp')
            dirs{k} = dirlist{1,j};
            k = k + 1;
        end
    end
elseif nargin == 1 && ischar(dirs)
    % Directory has been passed
    dirs = {dirs};
elseif nargin == 2
    % Compile a single file (given)
    html = true; pdf = true;
    if iscell(dirs), dirs = dirs{:}; end
    if strcmp(filename(end-1:end),'.m'), 
        filename = filename(1:end-2); 
    end
    cd(dirs);
    %%% HTML %%%
    if html
        % Clean up
        if exist('html','dir')
            delete(['html/',filename,'*.png'])
        end
        
        % Publish (to dirname/html/dirname.html)
        mypublish([filename,'.m'],opts); 
        
        % Make the filename clickable
        cd html
        curfile = [dirs,'/',filename,'.m']; 
        filetext = fileread([filename,'.html']);
        if shtml
            newtext = sprintf('<a href="/chebfun/examples/%s">%s</a>', ...
                curfile,curfile);
        else
            newtext = sprintf('<a href="%s">%s</a>', ...
                fullfile(examplesdir,dirs,[filename,'.m']),curfile);
        end
        filetext = strrep(filetext,curfile,newtext);
%         % Copyright notice
%         if shtml
%             filetext = strrep(filetext,'<p>Licensed under a Creative Commons 3.0 Attribution license','');
%             filetext = strrep(filetext,'<a href="http://creativecommons.org/licenses/by/3.0/">http://creativecommons.org/licenses/by/3.0/</a>','');
%             filetext = strrep(filetext,'by the author above.</p>','');
%         end

        if any(strcmp(filename,javalist))
%             filetext = strrep(filetext,'&lt;','<');
%             filetext = strrep(filetext,'&gt;','>');
                starts = strfind(filetext,'%&lt;a href="matlab: edit');
                for k = numel(starts):-1:1
                    endsk = strfind(filetext(starts(k):starts(k)+100),'&lt;/a');
                    strk = filetext(starts(k)+(0:endsk(1)+2));
                    idx1 = strfind(strk,'&gt;'); idx2 = strfind(strk,'&lt;');
                    newstr = strk(idx1(1)+4:idx2(2)-1);
                    filetext(starts(k)+(1:numel(newstr))) = newstr;
                    filetext(starts(k)+((numel(newstr)+1):endsk(1)+8)) = [];
%                         filetext(starts(k)+(0:endsk(1)+2)) = newstr;
                end
        end
        
        if strcmp(filename,'Writing3D')
            png = 'Writing3D_04.png';
            gif = 'Writing3D_04.gif';
            filetext = strrep(filetext,png,gif);
        end
        
        % Try to insert hyperlinks for references
        try
            refloc = strfind(lower(filetext),'reference');
            sourceloc = strfind(filetext,'SOURCE BEGIN');
            if isempty(sourceloc)
                reftext = filetext(refloc:end);
                sourcetext = [];
            else
                refloc(refloc>sourceloc) = [];
                refloc = refloc(end);
                reftext = filetext(refloc:sourceloc);
                sourcetext = filetext(sourceloc+1:end);
            end
            linklocs1 = strfind(reftext,'<a href'); 
            linklocs2 = strfind(reftext,'>');
            k = 1;
            while 1
                refk = ['[' int2str(k) ']'];
                idxk = strfind(reftext,refk);
                if isempty(idxk), break, end
                idx(k) = idxk;
                k = k+1;
            end
            bodytext = filetext(1:refloc-1);
            idx(k) = inf;
            for k = 1:numel(idx)-1
                startk = linklocs1(linklocs1>idx(k) & linklocs1<idx(k+1));
                endk = linklocs2(linklocs2>idx(k) & linklocs2<idx(k+1));
                if isempty(startk) || isempty(endk), continue, end
                strk = reftext(startk:endk);
                refk = ['[' int2str(k) ']'];
                bodytext = strrep(bodytext,refk,[strk,refk,'</a>']);
            end
            filetext = [bodytext reftext sourcetext];
        end

        fidhtml = fopen([filename,'.html'],'w+');
        fprintf(fidhtml,'%s',filetext);
        fclose(fidhtml);
        cd ..
    end
    %%% PDF %%%
    if pdf
        % Publish (to dirname/pdf/dirname.pdf)
        mypublish([filename,'.m'],optsPDF);        
        if strcmp(optsPDF.format,'latex') && isunix
            try
                cd pdf
                
                % Tidy up special characters
                filetext = fileread([filename,'.tex']);
                filetext = strrep(filetext,'ü','\"{u}');
                filetext = strrep(filetext,'ø','{\o}');
                filetext = strrep(filetext,'ó','\''{o}');
                filetext = strrep(filetext,'ö','\"{o}');
                filetext = strrep(filetext,'ő','\H{o}');
                filetext = strrep(filetext,'Ő','\H{O}');  
                filetext = strrep(filetext,'é','\''{e}');  
                
                % Fix a MATLAB bug!
                filetext = strrep(filetext,'$\$','$$');  

                if any(strcmp(filename,javalist))
                    starts = strfind(filetext,'%<a href="matlab: edit');
                    for k = numel(starts):-1:1
                        endsk = strfind(filetext(starts(k):starts(k)+100),'</a>');
                        strk = filetext(starts(k)+(0:endsk(1)+2));
                        idx1 = strfind(strk,'>'); idx2 = strfind(strk,'<');
                        newstr = strk(idx1(1)+1:idx2(2)-1);
                        filetext(starts(k)+(1:numel(newstr))) = newstr;
                        filetext(starts(k)+((numel(newstr)+1):endsk(1)+2)) = [];;
%                         filetext(starts(k)+(0:endsk(1)+2)) = newstr;
                    end
                end
                
                fidpdf = fopen([filename,'.tex'],'w+');
                fprintf(fidpdf,'%s',filetext);
                fclose(fidpdf);
                
                eval(['!latex ',filename])
                eval(['!dvipdfm ',filename])                
%                 ! rm *.aux *.log *.tex  *.dvi
                cd ../
            catch
                warning('CHEBFUN:examples:PDFfail','PDF PUBLISH FAILED.');
            end            
        end
    end
    cd ..
    
    % Upload to web server.
    if shtml
        curdir = pwd;
        cd(fullfile(webdir,'examples'))
        if ~exist(dirs,'dir'), mkdir(dirs), end
        cd(dirs)
        if ~exist('html','dir'), mkdir('html'), end
        if ~exist('pdf','dir'), mkdir('pdf'), end
        fprintf('Uploading html.\n')
        copyfile(fullfile(curdir,dirs,'html',[filename,'.html']),'html');
        try
            copyfile(fullfile(curdir,dirs,'html',[filename,'*.png']),'html');
        end
        if exist(fullfile(curdir,dirs,'html',[filename,'.shtml']),'file')
            copyfile(fullfile(curdir,dirs,'html',[filename,'.shtml']),'html');
        end
        if isunix, cd html, eval('!chgrp chebfun *'), eval('!chmod 775 *') , cd .., end
        fprintf('Complete.\n')
        fprintf('Uploading pdf.\n')
        copyfile(fullfile(curdir,dirs,'pdf',[filename,'.pdf']),fullfile('pdf',[filename,'.pdf']));
        fprintf('Complete.\n')
        fprintf('Uploading m files.\n')
        copyfile(fullfile(curdir,dirs,[filename,'.m']),[filename,'.m']);
        fprintf('Complete.\n')
        fprintf('Setting file permissions.\n')
        if isunix, cd pdf, eval('!chgrp chebfun *'), eval('!chmod 775 *') , cd .., end
        if isunix, eval('!chgrp chebfun *'), eval('!chmod 775 *'), end
        fprintf('Complete.\n')
        cd(curdir)
    end
    return
end

% Clean up
if clean
    fprintf('Cleaning. Please wait ...\n')
    for j = 1:numel(dirs)
        if ~exist(dirs{j},'dir'), continue, end
        cd(dirs{j})
        cd
        delete *.html *.shtml
        if exist('html','dir'), rmdir('html','s'), end
        if exist('pdf','dir'), rmdir('pdf','s'), end
        cd ..
    end
    fprintf('Done.\n')
    return
end

% Make index
if listing
    fprintf('Compiling index. Please wait ...\n')
    
    mfile = {}; filedir = {};
    % Find *all* the files.
    for j = 1:numel(dirs)
        % Move to the directory.
        if strcmp(dirs{j},'temp'), continue, end
        cd(dirs{j})
        % Find all the m-files.
        dirlist = dir(fullfile(pwd,'*.m'));
        mfile = [mfile dirlist.name];
        filedir = [filedir cellstr(repmat(dirs{j},numel(dirlist),1))'];
        cd ..
    end

    % Get the ordering (we need to ignore A and THE)
    desc = cell(numel(mfile),1); 
    for k = 1:numel(mfile)
        filename = mfile{k}(1:end-2);
        cd(filedir{k})
        % Grab the file description.
        fidk = fopen([filename,'.m']);
        txt = fgetl(fidk);
        origtxt = txt;
        txt = upper(txt);
        fclose(fidk);
        if txt < 1, continue, end % This mfile will be ignored
        if numel(txt) >1 && strcmp(txt(1:2),'%%')
            txt = txt(4:end);
        else
            txt = '     ';  % This mfile will be ignored
        end
        if strcmpi(txt(1:2),'A ')
            txt = txt(3:end);
        elseif strcmpi(txt(1:3),'AN ')
            txt = txt(4:end);             
        elseif strcmpi(txt(1:4),'THE ')
            txt = txt(5:end);
        end
        desc{k} = txt;
        origtxt = origtxt(4:end);
        if numel(origtxt) > 50
            idx = strfind(origtxt,':');
            if ~isempty(idx), origtxt = origtxt(1:idx(1)-1); end
        end
        origdesc{k} = origtxt;
        cd ..
    end
    [desc indx] = sort(desc);
    origdesc = origdesc(indx);
    mfile = mfile(indx);
    filedir = filedir(indx);
    
%     % Print data to file (list version)
%     fid = fopen('listing.html','w');
%     fprintf(fid,'<ul class="atap" style="padding-left:15px;">\n');
%     for k = 1:numel(mfile)
%          if isempty(desc{k}), continue, end
%          if strcmp(desc{k}(1),' '), continue, end
%          origdesc{k} = capitalize(origdesc{k});
%          mfile{k} = mfile{k}(1:end-2);
%          newtext = sprintf(['  <li>%s  <span style="float:right"><a href="%s/" ',...
%              'style="width:70px; display: inline-block;">%s</a>', ...
%              '(<a href="%s/html/%s.shtml">html</a>, <a href="%s/pdf/%s.pdf">PDF</a>, ',...
%              '<a href="%s/%s.m">M-file</a>)</span></li>\n\n'], ...
%                     origdesc{k},filedir{k},filedir{k},filedir{k},mfile{k},filedir{k},mfile{k},filedir{k},mfile{k});
%          fprintf(fid,newtext);
%     end
%     fclose(fid);
    
    % Print data to file (table version)
    fid = fopen('listing.html','w');
    if ~shtml
        fprintf(fid,'Here is the complete list of Chebfun Examples and the sections they belong to.<br/><br/>\n');
    end
    fprintf(fid,'<table style="padding-left:15px; cellpadding:2px; width:700px;">\n');
    ms = 0;
    for k = 1:numel(mfile)
         if isempty(desc{k}), continue, end
         if strcmp(desc{k}(1),' '), continue, end
%          origdesc{k} = capitalize(origdesc{k});
         mfile{k} = mfile{k}(1:end-2);
         ms = max(ms,length(origdesc{k}));
         if shtml
             newtext = sprintf(['  <tr>\n   <td style="text-transform: uppercase;">%s</td>\n', ...
                 '   <td style="float:right"><a href="%s/" style="width:70px; display: inline-block;">%s</a></td>\n', ...
                 '   <td>(<a href="%s/html/%s.shtml">html</a>, <a href="%s/pdf/%s.pdf">PDF</a>, ',...
                 '<a href="%s/%s.m">M-file</a>)</td>\n  </tr>\n\n'], ...
                        origdesc{k},filedir{k},filedir{k},filedir{k},mfile{k},filedir{k},mfile{k},filedir{k},mfile{k});
         else
             newtext = sprintf(['  <tr>\n   <td style="text-transform: uppercase;"><a href="%s/%s.m">%s</a></td>\n', ...
                 '   <td style="float:right">(<a href="%s/" style="width:70px; display: inline-block;">%s</a>)</td>\n  </tr>\n\n'], ...
                        filedir{k},mfile{k},origdesc{k},filedir{k},filedir{k});
         end
         fprintf(fid,newtext);
    end
    fprintf(fid,'<table>\n');
    fclose(fid);
    
%     % Print data to file (.txt version)
%     fid = fopen('LIST.txt','w');
%     fprintf(fid,'Below is a list of all the available Chebfun Examples in this directory\nMore can be found on the web at http://www.maths.ox.ac.uk/chebfun/examples/\n\n');
%     for k = 1:numel(mfile)
%          if isempty(desc{k}), continue, end
%          if strcmp(desc{k}(1),' '), continue, end
%          origdesc{k} = capitalize(origdesc{k});
%          ws = repmat(' ',1,ms-length(origdesc{k})+4);
% %          mfile{k} = mfile{k}(1:end-2);
%          newtext = sprintf('%s%s%s/%s.m\n',origdesc{k},ws,filedir{k},mfile{k});
%          fprintf(fid,newtext);
%     end
%     fclose(fid);

    if shtml 
        curdir = pwd;
        cd(webdir)
        fprintf([' Uploading. Please wait ... '])
        copyfile(fullfile(curdir,'listing.html'),'examples');
        cd(curdir)
        fprintf('Done.\n')
    end
    
    fprintf('Done.\n')
    return
end

% % Make examples.html
fid0 = fopen('examples.html','w+');
% Open template
fid_et1 = fopen('templates/examples_template1.txt','r');
% Read data.
tmp = fread(fid_et1,inf,'*char');
fclose(fid_et1);
% Write
fprintf(fid0,' %s',tmp);

% Sort the directories to match contents.txt
if numel(dirs) > 1 %|| iscell(dirs) && numel(dirs{1})
    fidc = fopen('contents.txt','r+');
    titletxt = fgetl(fidc);
    titles = [];
    while titletxt > 0
        titles = [titles ; titletxt(1:3)];
        titletxt = fgetl(fidc);
    end
    titles = cellstr(titles);
    titles(strcmp(titles,'tem')) = [];
    if numel(dirs) == numel(titles)
        [ignored idx1] = sort(titles);
        [ignored idx2] = sort(idx1);
        dirs = dirs(idx2);
    end        
end

if exampleshtml
    for j = 1:numel(dirs) 
        % Find the title of this directory
        fidc = fopen('contents.txt','r+');
        titletxt = fgetl(fidc);
        while ~strncmp(dirs{j},titletxt,3)
            titletxt = fgetl(fidc);
            if titletxt < 0, 
                error('CHEBFUN:examples:dirname', ...
                    ['Unknown directory name "',dirs{j},'. Update contents.txt.']);
            end        
        end
        titletxt = titletxt(length(dirs{j})+2:end);
        % Add entry to examples/examples.html
        if ~strcmp(dirs{j},'temp')
            fprintf(fid0,['<li><a href="',dirs{j},'/',dirs{j},'.html" style="text-transform: uppercase;">',titletxt,'</a>\n</li>\n\n']);
        end
    end
    % Open template
    fid_et2 = fopen('templates/examples_template2.txt','r');
    % Read data.
    tmp = fread(fid_et2,inf,'*char');
    fclose(fid_et2);
    % Write
    fprintf(fid0,' %s',tmp);
    fclose(fid0);
    return
end

% Loop over the directories.
for j = 1:numel(dirs)    
    % Find the title of this directory
    fidc = fopen('contents.txt','r+');
    prevdir = [];
    titletxt = fgetl(fidc);
    while ~strncmp(dirs{j},titletxt,numel(dirs{j}))
        prevdir = titletxt;
        titletxt = fgetl(fidc);
        if titletxt < 0, 
            error('CHEBFUN:examples:dirname', ...
                ['Unknown directory name "',dirs{j},'. Update contents.txt.']);
        end        
    end
    titletxt = titletxt(length(dirs{j})+2:end);
    
    % Add entry to examples/examples.html
    if ~strcmp(dirs{j},'temp')
        fprintf(fid0,['<li><a href="',dirs{j},'/',dirs{j},'.html">',titletxt,'</a>\n</li>\n\n']);
    end
    
    % Find the next and previous directories for breadcrumbs
    nextdir = fgetl(fidc);
    if isnumeric(nextdir)
        nextdir = [];
    else
        idx = strfind(nextdir,' ');
        nextdir = nextdir(1:idx-1);
    end
    if ~isempty(prevdir)
        idx = strfind(prevdir,' ');
        prevdir = prevdir(1:idx-1);
    end    
    fclose(fidc);
    if strcmp(nextdir,'temp'), nextdir = []; end
    if strcmp(dirs{j},'temp'), nextdir = []; prevdir = []; end
    
    % Move to the directory.
	cd(dirs{j})
    % Find all the m-files.
    dirlist = dir(fullfile(pwd,'*.m'));
    mfile = {dirlist.name};      
    
    % Make dirname/dirname.html
    fid = fopen([dirs{j},'.html'],'w+');
    % Write title
%     if shtml, fprintf(fid,['<div style="position:relative; left:-20px;">\n']);  end
    fprintf(fid,['                <h2>Chebfun Examples: ',titletxt,'</h2>\n']);
%     if shtml, fprintf(fid,'            </div>\n');  end
    if shtml
        % Make dirname/index.shtml
        make_shtml('index',dirs{j},[],titletxt,[],nextdir,prevdir);
    end
        
    % Get the ordering (we need to ignore A, AN, THE, ETC)
    desc = cell(numel(mfile),1); 
    for k = 1:numel(mfile)
        filename = mfile{k}(1:end-2);
               
        % Grab the file description.
        fidk = fopen([filename,'.m']);
        txt = fgetl(fidk);
        fclose(fidk);
        if txt < 1, continue, end % This mfile will be ignored
        if numel(txt) >1 && strcmp(txt(1:2),'%%')
            txt = txt(4:end);
        else
            txt = '     ';  % This mfile will be ignored
        end
        if strcmpi(txt(1:2),'A ')
            txt = txt(3:end);
        elseif strcmpi(txt(1:3),'AN ')
            txt = txt(4:end);            
        elseif strcmpi(txt(1:4),'THE ')
            txt = txt(5:end);
        end
        desc{k} = txt;
    end
    [desc indx] = sort(lower(desc));
    mfile = mfile(indx);
    
    % Loop over the files
    for k = 1:numel(mfile)
        filename = mfile{k}(1:end-2);
               
        % Grab the file description (again).
        fidk = fopen([filename,'.m']);
        txt = fgetl(fidk); fclose(fidk);
        if txt < 1, continue, end % Ignore this file.
        if numel(txt) >1 && strcmp(txt(1:2),'%%')
            txt = txt(4:end);
        else
            continue % This mfile will be ignored
%             txt = [filename,'.m'];
        end
        if numel(txt) > 50
            idx = strfind(txt,':');
            if ~isempty(idx), txt = txt(1:idx(1)-1); end
        end
%         fprintf(fid,['<span>',txt, '</span>     (']);
        fprintf(fid,['<span style="text-transform:uppercase;">',txt, '</span>     (']);
        
        % Make dirname/html/filename.shtml
        if shtml
            if k < numel(mfile), next = mfile{k+1}(1:end-2); else next = []; end
            if k > 1, prev = mfile{k-1}(1:end-2); else prev = []; end
            make_shtml(filename,filename,'html',(txt),titletxt,next,prev);
        end

        %%% HTML %%%
        if html
            % Publish (to dirname/html/dirname.html)
            try
                mypublish([filename,'.m'],opts);           

                % Make the filename clickable
                cd html
                curfile = [dirs{j},'/',filename,'.m']; 
                filetext = fileread([filename,'.html']);
                if shtml
                    newtext = sprintf('<a href="/chebfun/examples/%s">%s</a>', ...
                        curfile,curfile);
                else
                    newtext = sprintf('<a href="%s">%s</a>', ...
                        fullfile(examplesdir,dirs{j},[filename,'.m']),curfile);
                end
                filetext = strrep(filetext,curfile,newtext);
    %             % Copyright notice
    %             if shtml
    %             filetext = strrep(filetext,'<p>Licensed under a Creative Commons 3.0 Attribution license','');
    %             filetext = strrep(filetext,'<a href="http://creativecommons.org/licenses/by/3.0/">http://creativecommons.org/licenses/by/3.0/</a>','');
    %             filetext = strrep(filetext,'by the author above.</p>','');
    %             end
                fidhtml = fopen([filename,'.html'],'w+');
                fprintf(fidhtml,'%s',filetext);
                fclose(fidhtml);
                cd ..
            catch ME
                disp([dirs{j}, '/' ,filename ' CRASHED!'])
            end
            
        end
        
        if shtml && exist(fullfile('html',[filename,'.shtml']),'file')
        % Link to dirname/html/filename.shtml
            fprintf(fid,'<a href="html/%s.shtml">html</a>, ',filename);
        elseif exist(fullfile('html',[filename,'.html']),'file')
        % Link to dirname/html/filename.html
            link = fullfile('html',[filename,'.html']);
            fprintf(fid,'<a href="%s">html</a>, ',link);
        end
        
        %%% PDF %%%
%         if pdf
%             % Publish (to dirname/pdf/dirname.pdf)
%             try
%                 mypublish([filename,'.m'],optsPDF);
%                 if strcmp(optsPDF.format,'latex') && isunix
%                     
%                     cd pdf
%                     eval(['!latex ',filename])
%                     eval(['!dvipdfm ',filename])
%                     ! rm *.aux *.log *.tex  *.dvi
%                     cd ../
%                 end
%             catch
%                 warning('CHEBFUN:examples:PDFfail','PDF PUBLISH FAILED.#');
%             end
%         end

        if pdf
            % Publish (to dirname/pdf/dirname.pdf)
            mypublish([filename,'.m'],optsPDF);        
            if strcmp(optsPDF.format,'latex') && isunix
                try
                    cd pdf

                    % Tidy up special characters
                    filetext = fileread([filename,'.tex']);
                    filetext = strrep(filetext,'ü','\"{u}');
                    filetext = strrep(filetext,'ø','{\o}');
                    filetext = strrep(filetext,'ó','\''{o}');
                    filetext = strrep(filetext,'ö','\"{o}');
                    filetext = strrep(filetext,'ő','\H{o}');
                    filetext = strrep(filetext,'Ő','\H{O}');  
                    filetext = strrep(filetext,'é','\''{e}');  

                    % Fix a MATLAB bug!
                    filetext = strrep(filetext,'$\$','$$');  

                    if any(strcmp(filename,javalist))
                        starts = strfind(filetext,'%<a href="matlab: edit');
                        for k = numel(starts):-1:1
                            endsk = strfind(filetext(starts(k):starts(k)+100),'</a>');
                            strk = filetext(starts(k)+(0:endsk(1)+2));
                            idx1 = strfind(strk,'>'); idx2 = strfind(strk,'<');
                            newstr = strk(idx1(1)+1:idx2(2)-1);
                            filetext(starts(k)+(1:numel(newstr))) = newstr;
                            filetext(starts(k)+((numel(newstr)+1):endsk(1)+2)) = [];;
    %                         filetext(starts(k)+(0:endsk(1)+2)) = newstr;
                        end
                    end

                    fidpdf = fopen([filename,'.tex'],'w+');
                    fprintf(fidpdf,'%s',filetext);
                    fclose(fidpdf);

                    eval(['!latex ',filename])
                    eval(['!dvipdfm ',filename])                
    %                 ! rm *.aux *.log *.tex  *.dvi
                    cd ../
                catch
                    warning('CHEBFUN:examples:PDFfail','PDF PUBLISH FAILED.');
                end            
            end
        end
    
        
        % Link to dirname/pdf/<filename>.pdf
%         if exist(fullfile('pdf',[filename,'.pdf']),'file')
            if shtml
                link = ['pdf/',filename,'.pdf'];
            else
                link = fullfile('pdf',[filename,'.pdf']);
            end
%             fprintf(fid,['<a href="',link,'" target="_blank">PDF</a>, ']);
            fprintf(fid,'<a href="%s">PDF</a>, ',link);
%         end
        
        %%% M-FILES %%%
        fprintf(fid,'<a href="%s.m">M-file</a>)\n',filename);
        fprintf(fid,'                <br/>\n\n');   

    end
    fclose(fid);

    fprintf([dirs{j},' published\n'])
    cd ..
end

% Open template
fid_et2 = fopen('templates/examples_template2.txt','r');
% Read data.
tmp = fread(fid_et2,inf,'*char');
fclose(fid_et2);
% Write
fprintf(fid0,' %s',tmp);
fclose(fid0);

% Upload to web server.
if shtml
%     fprintf('Copy the following to a bash terminal:\n')
%     fprintf(['cp -r ',pwd,' ',webdir,'\n'])

    curdir = pwd;
    try
        cd(fullfile(webdir,'examples'))
    catch
        fprintf('No connection to Chebfun server. Exiting.\n')
        return
    end
    
    
    for j = 1:numel(dirs)
        fprintf(['Uploading ',dirs{j},'. Please wait ... '])
        if ~exist(dirs{j},'dir'), mkdir(dirs{j}), end
        copyfile(fullfile(curdir,dirs{j},'*.m'),dirs{j});
        cd(dirs{j});
        copyfile(fullfile(curdir,dirs{j},[dirs{j},'.html']),[dirs{j},'.html']);
        copyfile(fullfile(curdir,dirs{j},'index.shtml'),'index.shtml');
        if ~exist('html','dir'), mkdir('html'), end
        if ~exist('pdf','dir'), mkdir('pdf'), end
        if exist(fullfile(curdir,dirs{j},'html'),'dir')
            copyfile(fullfile(curdir,dirs{j},'html','*.shtml'),'html');
            if html
                if isunix
                    eval(['!cp ',fullfile(curdir,dirs{j},'html','*.html') ' html']); 
                    eval(['!cp ',fullfile(curdir,dirs{j},'html','*.png') ' html']);
                else
                    copyfile(fullfile(curdir,dirs{j},'html','*.html'),'html');
                    copyfile(fullfile(curdir,dirs{j},'html','*.png'),'html');
                end
            end
        if isunix
            eval(['!chmod -R 775 ','html']); 
            eval(['!chgrp -R chebfun ','html/*']); 
        end
        end
        if pdf && exist(fullfile(curdir,dirs{j},'pdf'),'dir')
            copyfile(fullfile(curdir,dirs{j},'pdf','*.pdf'),'pdf');
            if isunix
                eval(['!chmod -R 775 ','pdf']);
                eval(['!chgrp chebfun ','pdf/*']);
            end
        end
        cd ..
        if isunix
            eval(['!chmod 775 *']);
            eval(['!chmod -R 775 ',dirs{j}]);
            eval(['!chgrp -R chebfun ',[dirs{j},'/*']]);
        end  
        fprintf('Complete.\n')
    end
    cd(curdir)
    return
end



function make_shtml(file1,file2,dir,title,dirtitle,next,prev)
if nargin < 3, dir = []; end
% Create the files.
if ~isempty(dir)
    if ~exist(fullfile(dir),'dir')
        mkdir html
    end
    fid = fopen([dir,'/', file1,'.shtml'],'w+');
else
    fid = fopen([file1,'.shtml'],'w+');
end

% Open the templates.
fid1 = fopen('../templates/template1.txt','r');
% Template 3 has the footer contact info, whereas 2 doesn't.
if ~isempty(dir)
%     fid2 = fopen('../templates/template2.txt','r');
    fid2 = fopen('../templates/template3.txt','r');
else
    fid2 = fopen('../templates/template3.txt','r');
end

% Read their data.
tmp1 = fread(fid1,inf,'*char');
tmp2 = fread(fid2,inf,'*char');
fclose(fid1);
fclose(fid2);

% Write to file.
if ~isempty(dir)
    fprintf(fid,'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">');
else
    fprintf(fid,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
    fprintf(fid,'\n<html xmlns="http://www.w3.org/1999/xhtml">\n');
end

% HEAD
fprintf(fid,'\n<head>\n');
% TITLE
fprintf(fid,'<title>%s</title>\n',(title)); % Lower case
% fprintf(fid,'<title>%s</title>\n',capitalize(title)); % Captialised

% META DATA
if ~isempty(dir)
    v = version; indx = strfind(v,'.'); v = v(1:indx(2)-1);
    fprintf(fid,'<meta name="generator" content="MATLAB %s">\n',v);
    fprintf(fid,'<link rel="schema.DC" href="http://purl.org/dc/elements/1.1/">\n');
    fprintf(fid,'<meta name="DC.date" content="%s">\n',datestr(now, 'yyyy-mm-dd'));
    fprintf(fid,'<meta name="DC.source" content="%s.m">\n',file1);
end

% TEMPLATE1
fwrite(fid, tmp1);

% BREADCRUMBS
if ~isempty(dir)
    % 2nd level
    fprintf(fid,'            <div id="breadcrumb">\n            <table id="bctable"><tbody><tr>\n');
    fprintf(fid,'            <td> > <a href="../../">examples</a> > <a href="../" class="lc">%s</a>',dirtitle);
    if ~isempty(prev)
        fprintf(fid, ' | <a href="%s.shtml">previous</a>',prev);
    else
        fprintf(fid, ' | previous');
    end
    if ~isempty(next)
        fprintf(fid, ' | <a href="%s.shtml">next</a>',next);
    else
        fprintf(fid, ' | next');
    end
    fprintf(fid,'</td>\n');
    fprintf(fid,'            <td style="text-align:right"> also available as: <a href="../pdf/%s.pdf">PDF</a> | <a href="../%s.m">M-file</a></td>\n',file1,file1);
    fprintf(fid,'            </tr></tbody></table>\n            </div>\n');
else
    % 1st level
    fprintf(fid,'            <div id="breadcrumb">\n            <table id="bctable"><tbody><tr>\n');
    fprintf(fid,'            <td> > <a href="../">examples</a>');
    if ~isempty(prev)
        fprintf(fid, ' | <a href="../%s/">previous</a>',prev);
    else
        fprintf(fid, ' | previous');
    end
    if ~isempty(next)
        fprintf(fid, ' | <a href="../%s/">next</a>',next);
    else
        fprintf(fid, ' | next');
    end
    fprintf(fid,'</td>\n            </tr></tbody></table>\n</div>\n');
end
% HTML INCLUDE
fprintf(fid,'            <!--#include virtual="%s.html" -->\n',file2);
% TEMPLATE 2
fwrite(fid, tmp2);
fclose(fid);


function mypublish(varargin)
close all
evalin('base','clear all');
chebfunpref('factory'), cheboppref('factory')
publish(varargin{:});
chebfunpref('factory'), cheboppref('factory')
close all

function txt = capitalize(txt)
txt = lower(txt);
txt(1) = upper(txt(1));
for k = 1:numel(txt)-1;
    tk = txt(k);
    if strcmp(tk,' ') || strcmp(tk,'-') || strcmp(tk,'(') || strcmp(tk,'[') || strcmp(tk,'/') || (~isempty(str2num(tk)) && isreal(str2num(tk)))
        txt(k+1) = upper(txt(k+1));
    end
end

txt = [txt '    '];

for k = 1:numel(txt)-4;
    tk = txt(k:k+4);
    if strncmp(tk,'A ',2)
        txt(k:k+1) = lower(tk(1:2));
    elseif strncmp(tk,'In ',3) || strncmp(tk,'Of ',3) || strncmp(tk,'At ',3) || strncmp(tk,'As ',3) || strncmp(tk,'An ',3)
        txt(k:k+2) = lower(tk(1:3));
    elseif strncmp(tk,'The ',4) || strncmp(tk,'And ',4) || strncmp(tk,'Its ',4) || strncmp(tk,'For ',4) || strncmp(tk,'Via ',4)
        txt(k:k+3) = lower(tk(1:4));
    elseif strcmp(tk,'With ')
        txt(k:k+4) = lower(tk);
    elseif strncmp(tk,'Ode',3) || strncmp(tk,'Pde',3) || strncmp(tk,'Bvp',3)
        txt(k:k+2) = upper(tk(1:3));
    end
end

txt = txt(1:end-4);
txt(1) = upper(txt(1));
% end