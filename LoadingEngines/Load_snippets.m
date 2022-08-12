function [T,WV] = Load_snippets(varargin)
% Getting data from the snippet extractor to MClust 
% Quick and dirty version for testing purposes

MCD = MClust.GetData();
snippets = MCD.Snippets;
T=snippets.T;
WV=snippets.WV;

% convert to tsd object
% WV = tsd(T, WV);
