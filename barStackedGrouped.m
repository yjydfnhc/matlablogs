%using Matlab2017a  
%(a section from TechMain.m)
%% %=====23.5. (only for log: desc+top10) literal portion of gold standard and desc in one figure
 
sqlstrParamed_desc = strcat('select avg(litNum), avg(littypeNum), avg(totalTNum-littypeNum), avg(totalTNum) '...
, ' from web_entities '...
, ' where c="%s" ');

sqlstrParamed_gold = strcat('select avg(litNum_%s), avg(littypeNum_%s) '...
, ' from web_ana_result '...
, ' where eid in (select id from web_entities where c="%s") ');
typeNames       ={'Agent','Event','Location','Species', 'Work','film','Person'};%must be consistant with the dataset
typeNamesDisplay={'Agent','Event','Location','Species', 'Work','Film','Person'};

topkNames = {'top5', 'top10'};

typeNum = size(typeNames, 2)


for kid=2%1%1:2
    topk=topkNames(kid);
    topk = cell2mat(topk) %topk='top10';%'top5'
    k = kid*5;
    barVal=[];%each row for one type, each column for a source(i.e. gold, gold-neg, desc)
    avgValues=[];
    stdValues=[];
    for tid=1:typeNum%1:7 %7types
        typeName = typeNames(tid);
        typeName = cell2mat(typeName);
        %=== 1. desc
        sqlstr_desc = sprintf(sqlstrParamed_desc, typeName)
        result = select(conn, sqlstr_desc)%1*4 table
        metricVec = table2array(result)%1*4 vec
        litNum = metricVec(1)
        littypeNum = metricVec(2)
        resNum = metricVec(3)
        totalNum = metricVec(4)
        typeNum = littypeNum-litNum
        
        valVec = [litNum typeNum resNum]
        barVal=[barVal; valVec]
                
        %=== 2. gold
        sqlstr_gold = sprintf(sqlstrParamed_gold, topk, topk, typeName)
        result = select(conn, sqlstr_gold)%1*2 table
        metricVec = table2array(result)%1*2 vec
        litNum=metricVec(1)
        littypeNum=metricVec(2)
        totalNum = k
        typeNum = littypeNum-litNum
        resNum = totalNum-littypeNum
        
        valVec = [litNum typeNum resNum]
        barVal=[barVal; valVec]        
        
        %=== 2. add zeros (to seperate different groups)
        valVec = [0 0 0] 
        barVal=[barVal; valVec]
    end
fig=figure;
h1=bar(barVal,'stacked');%====== draw figure, 
%====  barVal is a matrix, each row corresponding to one stacked bar, 
%====  each column corresponding to length of a stack in the bar,
%====  groups are seperated by a zero-valued row;


set(gca,'xticklabel',typeNamesDisplay);
legend({'Literal','Type','Resource'});
legend('Location', 'NorthOutside', 'Orientation', 'horizontal');
legend('show');
width=1200;%800;
height=400;%300;
set(fig, 'Position', [0, 0, width, height]);
set(gca,'XLim',[0 21],'XTick',1.5:3:21,'XTickLabel',typeNamesDisplay);   %======# Modify axes
%==== 'XLim' sets the length of the x-axes;
%==== 'XTick' sets the position of xticklabels;



set(findall(gcf,'type','axes'),'fontsize',defaultFontSize);  % set fonsize
set(findall(gcf,'type','text'),'fontSize',defaultFontSize) ;
% saveas(gcf,strcat('D:/work/matlabworkspace/esumm/evalFig/figs/tech-one_litnum_',topk),'epsc');
% saveas(gcf,strcat('D:/work/matlabworkspace/esumm/evalFig/figs/tech-one_litnum_',topk),'fig');
end
