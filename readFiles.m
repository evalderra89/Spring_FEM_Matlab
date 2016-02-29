%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: This function reads the input file.
% Written By: Esteban Valderrama, 11/25/2015
%             University of Wisconsin at Platteville
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Inputs
% file -> input file.
%%  Outputs
% nodes          -> Number of nodes in the system.
% elementNodes   -> Matrix of [numberElements x 2].
% numberElements -> Number of elemets (springs).
% F     -> Force vector of [nodes x 1].
% K     -> Element Stiffness matrix.
%          NOTE: The element stiffness matrix is defined in two forms:
%                - [nodes x nodes] if all the spring has the same value.
%                - [nodes x nodes x # of diff. K] if the spring have
%                different K values.
% n     -> Number of different K values in the system.
% u     -> Displacements vector [nodes x 1].
% ind_u -> vector of [node with BC x 1].
%
%%  Input file definition
% You have to create an input file in a .txt file, see the following
% example:

% $Nodes           -> Keyword always present
% 4                -> Number of nodes of the system
% $Elements        -> Keyword always present
% 3                -> Number of elements in the system
% 1 1 2            -> First column, contains the element number
% 2 2 3            -> Second and third columns, contains the nodes for the
% 3 2 4                                         element
% $Forces          -> Keyword always present
% 2                -> Number of forces BC in the system (if there are not forces type 0)
% 2 10             -> First column, contains the node number
% 4 30             -> Second column, contains the force value
% $Displacements   -> Keyword always present
% 3                -> Number of displacements BC in the system
% 1 0              -> First column, contains the element number
% 3 0              -> Second column, contains the displacement value
% 4 0
% $Stiffness       -> Keyword always present
% $Same            -> Keyword always present ($Same or $Diff)
% 1                -> Value for K
% $end             -> Keyword always present
%
% NOTE: if the stiffness is different on each element, follow these
%       instructions.
%
% $Stiffness       -> Keyword always present
% $Diff            -> Keyword always present ($Same or $Diff)
% 3                -> Number of different K in the system
% 1 1000           -> First column, contains the element number
% 2 2000           -> Second column, contains the K value in the element
% 3 3000
%%
function [nodes, elementNodes, numberElements, F, stiffness, n_stiffness, u, ind_u, ind_F] = readFiles(file)

fid = fopen(file);
[fid, message] = fopen(file,'r');
if(fid < 0)
    fprintf('Filename: %s. \n %s\n',file,message)
    error('error opening file: ')
    return
end

% Read Nodes
fscanf(fid,'$Nodes\n',1);
nodes = fscanf(fid,'%d\n',1);
mline = fgetl(fid);
numberElements = fscanf(fid,'%d\n',1);

elementNodes = zeros(numberElements,2);
u = zeros(nodes,1);
F = zeros(nodes,1);

% Read Elements
if strcmp(mline, '$Elements')
    for i = 1:numberElements
        conn(i,:) = fscanf(fid,'%d %d %d \n',3);
    end
end

for i = 1:size(conn,1)
    elems(i,1) = conn(i,1);
    elementNodes(i,:) = conn(i,2:3);
end

% Read Forces
mline = fgetl(fid);
if strcmp(mline, '$Forces')
    nF = fscanf(fid,'%d\n',1);
    for i = 1:nF
        bcForce(i,:) = fscanf(fid,'%f %f \n',2);
    end
end

% Save Forces in Vector
if nF ~= 0
    for i = 1:size(bcForce,1)
        ind_F(i,1) = bcForce(i,1);
        F(ind_F(i,1)) = bcForce(i,2);
    end
else
    ind_F = 0;
    bcForce = 0;
end

% Read Displacements
mline = fgetl(fid);
if strcmp(mline, '$Displacements')
    nD = fscanf(fid,'%d\n',1);
    for i = 1:nD
        bcDisp(i,:) = fscanf(fid,'%f %f \n',2);
    end
end

% Save Displacements in Vector
if nD ~= 0
    for i = 1:size(bcDisp,1)
        ind_u(i,1) = bcDisp(i,1);
        u(bcDisp(i,1)) = bcDisp(i,2);
    end
end

% Read Stiffness Constant
fscanf(fid,'$Stiffness\n',1);
mline = fgetl(fid);
if strcmp(mline,'$Same')
    n_stiffness = 1;
    stiffness = fscanf(fid,'%d\n',1);
elseif strcmp(mline,'$Diff')
    n_stiffness = fscanf(fid,'%d\n',1);
    stiffness = zeros(n_stiffness,2);
    for i = 1:n_stiffness
        stiffness(i,:) = fscanf(fid,'%d%f\n',2);
    end
end