function sysDisplay(sys)
figure


% --- show the anchor and fairlead positions globally ---
for ianch = 1:size(sys.anchorPos,2)
    scatter3(sys.anchorPos(1,ianch), ...
             sys.anchorPos(2,ianch), ...
             sys.anchorPos(3,ianch), 'red');hold on
    text(sys.anchorPos(1,ianch)+10, ...
         sys.anchorPos(2,ianch), ...
         sys.anchorPos(3,ianch), num2str(ianch), 'Color','k','fontSize',14);hold on
end

for ifair = 1:size(sys.fairleadPos_init,2)
    scatter3(sys.fairleadPos_init(1,ifair), ...
             sys.fairleadPos_init(2,ifair), ...
             sys.fairleadPos_init(3,ifair), 'b');hold on
    text(sys.fairleadPos_init(1,ifair)+10, ...
         sys.fairleadPos_init(2,ifair), ...
         sys.fairleadPos_init(3,ifair), num2str(ifair), 'Color','k','fontSize',14);hold on
end

% --- show the pairing of anchors and fairleads globally ---
for iAline = 1:size(sys.anchorLinePair,1)
    xConnect = [sys.anchorPos(1,sys.anchorLinePair(iAline,1)), sys.fairleadPos_init(1,sys.anchorLinePair(iAline,2))];
    yConnect = [sys.anchorPos(2,sys.anchorLinePair(iAline,1)), sys.fairleadPos_init(2,sys.anchorLinePair(iAline,2))];
    zConnect = [sys.anchorPos(3,sys.anchorLinePair(iAline,1)), sys.fairleadPos_init(3,sys.anchorLinePair(iAline,2))];
    plot3( xConnect, yConnect, zConnect, 'k:');hold on
end

for iSline = 1:size(sys.sharedLinePair,1)
    xConnect = [sys.fairleadPos_init(1,sys.sharedLinePair(iSline,1)), sys.fairleadPos_init(1,sys.sharedLinePair(iSline,2))];
    yConnect = [sys.fairleadPos_init(2,sys.sharedLinePair(iSline,1)), sys.fairleadPos_init(2,sys.sharedLinePair(iSline,2))];
    zConnect = [sys.fairleadPos_init(3,sys.sharedLinePair(iSline,1)), sys.fairleadPos_init(3,sys.sharedLinePair(iSline,2))];
    plot3( xConnect, yConnect, zConnect, 'k:');hold on
end


% --- show the initial configurations of lines  ---
for iAline = 1:size(sys.anchorLinePair,1)
    plot3(sys.anchorLine(iAline).shapeGlobal_init(1,:),...
          sys.anchorLine(iAline).shapeGlobal_init(2,:),...
          sys.anchorLine(iAline).shapeGlobal_init(3,:), 'k');hold on
end


for iSline = 1:size(sys.sharedLinePair,1)
    plot3(sys.sharedLine(iSline).shapeGlobal_init(1,:),...
          sys.sharedLine(iSline).shapeGlobal_init(2,:),...
          sys.sharedLine(iSline).shapeGlobal_init(3,:), 'k');hold on
end



axis equal
            
end