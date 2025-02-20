function forvbFRET()
% FORHAMMY  Converts fluorescence data into HaMMy format
%
%   Prompts user for location of traces file (output from autotrace)
%   to convert.  Output extension is .dat.  The original is left intact.
%   
% http://vbfret.sourceforge.net/
% FORMAT: <donor intensity> <acceptor intensity> ...
% one column per trace, two columns per molecule.
% NOTE: donor dark regions are removed before passing it on.

%   Copyright 2007-2015 Cornell University All Rights Reserved.


% Get filename from user
[name,filepath]=uigetfile('*.traces','Choose a fret file:');
if name==0,  return;  end
filename = strcat( filepath, filesep, name );


% Load the traces files
data = loadTraces( filename );
[Ntraces,Nframes] = size(data.donor);

% Calculate lifetimes
% lifetimes = CalcLifetime( donor+acceptor )-2;

% Initialize the output matrix (2 columns for each trace: donor and acceptor)
output = zeros(Nframes, Ntraces * 2);

% Small value to replace donor zeros
small_value = 0.001;

for i = 1:Ntraces
    % Identify donor and acceptor dark regions where FRET data is zero
    window = data.fret(i,:) ~= 0;  % FRET data not equal to zero
    
    % Replace donor values with small_value where FRET is zero
    data.donor(i, ~window) = small_value;  % Replace donor with small_value where FRET is zero
    
    % Set acceptor values to zero where FRET is zero
    data.acceptor(i, ~window) = 0;  % Set acceptor to 0 where FRET is zero
    
    % Assign donor and acceptor data to the output matrix (column-wise)
    output(:, (2 * (i - 1)) + 1) = data.donor(i,:)';  % Donor values for trace i
    output(:, 2 * i) = data.acceptor(i,:)';           % Acceptor values for trace i
end


% Save data to file
outfile = strrep(filename,'.traces','_vbFRET.dat')

% Write header (trace names).
fid = fopen(outfile,'w');
ids = num2cell( ceil(0.5:0.5:Ntraces) );
[~,baseName] = fileparts(filename);
baseName = strrep( baseName, ' ','_' );

fprintf( fid, [baseName '%04d\t' baseName '%04d\t'], ids{:} );
fprintf( fid, '\n' );

% Write file to disk as a vector (columnwise through <data>)
dlmwrite( outfile, output, '-append', 'delimiter','\t' );


end % function forvbFRET

