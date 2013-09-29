classdef ProcManager
    % Morgan Frank (24/6/13)
    % ProcManager.m is a modest datastructure that allows parallel
    % processing of matlab functions among up to 12 processors. To reserve
    % a specified number of processors, N, simply create an instance of
    % ProcManager (ex: M=ProcManager(N)). The constructor of this class
    % will attempt to close any existing parallel matlab "labs" and then 
    % create N new ones. To close the processor manager properly, execute
    % M.close(). This method will close all parallel matlab "labs". With
    % an active ProcManager instance M, a function handle, F, can be 
    % executed in
    % parallel using M.run(F,x1,x2,x3,.....) or M.runN(n,F,x1,x2,x3,...).
    % runN() allows the user to specify the number of processors to run the
    % function on (n), while run() runs the function on all available
    % processors. Both run() and runN() return a cell array called "outs".
    % Each entry in outs is the output from each processors' execution of
    % the function handle F. The function F has access to two constants:
    %       numlabs=the number of active parallel matlab "labs". If using
    %       run(F,x1,...), then numlabs=M.numProcs. If using 
    %       runN(n,F,x1,...), then numlabs=n.
    %       labindex= a number representing which processor the function is
    %           being run on (ex: 1,2,3,...). This constant is helpful for
    %           separating pieces of a process, like constructing a matrix,
    %           and also useful for identifying which output came from
    %           which function execution.
    %   Furthermore, the function F must ONLY RETURN ONE OUTPUT!!! Note
    %   that the output can be a cell-array containing as many entries as
    %   you want. 
    % Example 1:
    %   A simple example of distributing a simple computation.
    %   M=ProcManager(4); % creates ProcManager with 4 processors
    %   M.runN(3,@(x,y)[labindex+x+y,labindex],5,6)
    %   ans = 
    %    {[12,1]    [13,2]    [14,3]}
    %
    % Example 2:
    %   In this example we distribute the construction of a possibly large 
    %   matrix.
    %   function Mat=matBuild()
    %       Mat=zeros(10);
    %       for i=labindex:numlabs:10
    %           Mat(:,i)=i*ones(10,1);
    %       end;
    %   end
    %
    %   M=ProcManager(4);
    %   out=M.run(@matBuild);
    %   Mat=out{1}
    %   for i=2:4
    %       Mat=Mat+out{i};
    %   end;
    %
    %   Mat =
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %      1     2     3     4     5     6     7     8     9    10
    %
   properties
       numProcs;
   end;
   methods
       function obj=ProcManager(num)
           % creates an instance of the processor manager.
           % Input:
           %    num = number of processors to request.
            obj.numProcs=num;
            try
                matlabpool close;
            end;
            matlabpool(num);
       end;
       
       function outs=run(obj,funct,varargin)
           spmd
               out=funct(varargin{:});
           end;
           outs=cell(1,obj.numProcs);
           for i=1:obj.numProcs
               outs{i}=out{i};
           end;
       end;
       
       function outs=runN(obj,N,funct,varargin)
           spmd(N)
               out=funct(varargin{:});
           end;
           outs=cell(1,N);
           for i=1:N
               outs{i}=out{i};
           end;
       end;
   end;
   methods(Static)
       function close()
           matlabpool close;
       end;
   end;
end