%show ratio not difference
function BATS
    home = figure('Position', [300,400,800,800], 'Name', 'Beacon Attraction Trajectory Simulation', 'NumberTitle', 'off', 'menubar', 'none', 'Color', 'w'); %Visible off while adding components, Size of window, Name of figure, Turn off the figure number
    logo = imread('BATSLogo.png');
    axes('position',[.31 .5 0.4 0.4]);
    imagesc(logo);
    enter = uicontrol('Style', 'pushbutton', 'String', 'Enter', 'Position', [343 70 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 18, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @mainFigure); 
    welcome = uicontrol('Style', 'text', 'String', 'Welcome to B.A.T.S.', 'Position', [210 260 400 50], 'FontSize', 40, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    info = uicontrol('Style', 'text', 'String', 'B.A.T.S. allows users to simulate the beacon attraction trajectory on simple polygons and compare that trajectory to the shortest path.', 'ForegroundColor', [0.1, 0.4, 1], 'Position', [210 150 400 100], 'FontSize', 15, 'BackgroundColor', 'w');
    set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
    sp = 0;
    algorithmButton = 0;
    startButton = 0;
    changeBeacon = 0;
    changeStart = 0;
    createPolygon = 0;
    showNorm = 0;
    diffArea = 0;

    function mainFigure(~, ~)
        delete(enter)
        delete(welcome)
        delete(info)
        sp = subplot('Position', [0.2 0.15 0.75 0.75], 'Color', [0.95, 0.95, 1]); %position the plot inside the window
        uicontrol('Style', 'text', 'String', 'DISTANCE TO BEACON:', 'Position', [10 120 140 120], 'Foreground', [0.1, 0.4, 1], 'FontSize', 12, 'BackgroundColor', [0.9 0.9 0.9]);
        uicontrol('Style', 'popup', 'String', {'Choose a Polygon', 'Polygon1', 'Polygon2', 'Polygon3'}, 'Position', [20 540 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @changePolygon);%selects polygon to use, dropdown menu, calls function changePolygon    
        algorithmButton = uicontrol('Style', 'popup', 'String', {'Choose an Algorithm', 'B.A.T.', 'S.P.', 'Create Path', 'All Paths'}, 'Position',[20 490 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'HandleVisibility','off', 'Enable', 'off');
        startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Enable', 'off'); 
        changeBeacon = uicontrol('Style', 'pushbutton', 'String', 'Change Beacon', 'Position', [24 460 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @setBeacon, 'Enable', 'off'); 
        changeStart = uicontrol('Style', 'pushbutton', 'String', 'Change Start Point', 'Position', [24 400 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @setStart, 'Enable', 'off'); 
        createPolygon = uicontrol('Style', 'pushbutton', 'String', 'Create Polygon', 'Position', [24 350 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @newPolygon, 'Enable', 'on'); 
        showNorm = uicontrol('Style', 'radiobutton', 'String', 'Show Normals', 'Position', [600 620 100 20], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [1, 1, 1], 'Callback', @showNormals, 'Enable', 'on');
        uicontrol('Style', 'pushbutton', 'String', 'Reset!', 'Position', [610 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 20, 'BackgroundColor', [0.95, 0.95, 1], 'FontWeight', 'bold', 'Callback', @resetSim); 
        uicontrol('Style', 'pushbutton', 'String', 'Home', 'Position', [190 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 20, 'BackgroundColor', [0.95, 0.95, 1], 'FontWeight', 'bold', 'Callback', @backHome);
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
        axis([0 10 0 10]);
    end
    G = 0;
    normalX = 0;
    normalY = 0;
    stopCreate = 0;
    pointNode = 1;
    beaconNode = 2;
    lastLineX = [0 0];
    lastLineY = [0 0];
    numNodes = 0;
    nLabel = {};
    pathBAT = 0;
    stopPoint = [-1 -1];
    lengthBATPath = 0;
    lengthSPPath = 0;
    startNode = 0;
    endNode = 0;
    p = 0;
    px = 0;
    py = 0;
    currX = -1;
    currY = -1;
    countCreatePath = 1;
    lengthCreatePath = 0;
    createPath = 0;
    polygonSource = 0;
    editStart = 0;
    editBeacon = 0;
    diff = 0;
    
    function changePolygon(source,~)
        set(createPolygon, 'Enable', 'on');
        set(startButton, 'Enable', 'off');
        set(algorithmButton, 'Enable', 'off');
        set(changeBeacon, 'Enable', 'off');
        set(changeStart, 'Enable', 'off');
        set(showNorm, 'Enable', 'on');
        if diff ~= 0
            delete(diffArea);
        end
        uicontrol('Style', 'text', 'String', 'DISTANCE TO BEACON:', 'Position', [10 120 140 120], 'Foreground', [0.1, 0.4, 1], 'FontSize', 12, 'BackgroundColor', [0.9 0.9 0.9]);
        polygonSource = source;
        % Determine the selected data set.
        str = get(polygonSource, 'String');
        val = get(polygonSource,'Value');
        % Set current data to the selected data set.
        switch str{val};
            case 'Polygon1' %create the first polygon
                cla reset;
                clearvars -global;
                G = 0;
                endPoint = [-1 -1];
                count = 1;
                lengthBATPath = 0;
                stopPoint = [-1 -1];
                nLabel = {};
                lastLineX = [0 0];
                lastLineY = [0 0];
                startNode = 0;
                endNode = 0;
                p = 0;
                numNodes = 0;
                if editBeacon == 0 && editStart == 0
                    px = [9 1.5 10 9.8 3.6 3.8 2.6 2.5 0.8 1.3 0.1 0.2 3.3 4.7 5.4];
                    py = [0.3 0.6 0.1 2.4 2.4 1.3 2.2 1.1 1.7 0.9 1.3 0.1 0.1 1.7 0.1]; 
                end
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon((line2x(1) + line2x(2))/2, (line2y(1) + line2y(2))/2, px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distanceToStart = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distanceToStart; 
                end
                
                startPoint = [px(1) py(1)];
                beacon = [px(2) py(2)];
                pathPosition = 1;
                pathTempX = zeros(numNodes*2);
                pathTempY = zeros(numNodes*2);
                distanceStartToBeacon = sqrt((startPoint(1) - beacon(1))^2+(startPoint(2) - beacon(2))^2);
                options = optimset('Display','off');
                while (startPoint(1) ~= beacon(1)) || (startPoint(2) ~= beacon(2))  
                    pathTempX(pathPosition) = startPoint(1);
                    pathTempY(pathPosition) = startPoint(2);
                    pathPosition = pathPosition + 1;
                    line1x = [startPoint(1) beacon(1)];
                    line1y = [startPoint(2) beacon(2)];
                    closestLine = 100000;
                    closestDist = 100000;
                    for i = 3 : numNodes
                        if (i+1) > numNodes
                            line2x = [px(i) px(3)];
                            line2y = [py(i) py(3)];
                            slope2(i) = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                        else
                            line2x = [px(i) px(i+1)];
                            line2y = [py(i) py(i+1)];
                            slope2(i) = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                        end
                        fit1 = polyfit(line1x, line1y, 1);
                        fit2 = polyfit(line2x, line2y, 1);
                        x_inter(i) = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                        y_inter = round(polyval(fit1, x_inter), 14);
                        if (x_inter(i) > min(line2x)) && (x_inter(i) < max(line2x)) && (y_inter(i) > min(line2y)) && (y_inter(i) < max(line2y))
                            distanceToStart = sqrt((x_inter(i) - startPoint(1))^2+(y_inter(i) - startPoint(2))^2);
                            distanceToBeacon = sqrt((x_inter(i) - beacon(1))^2+(y_inter(i) - beacon(2))^2);
                            if (distanceToStart < closestDist) && (distanceToBeacon < distanceStartToBeacon) && inpolygon(x_inter(i), y_inter(i), line1x, line1y)
                                closestLine = i;
                                closestDist = distanceToStart;
                            end
                        end
                    end
                    %find intersecting line with perpendicular
                    if closestLine ~= 100000 && (closestLine + 1) > numNodes
                        lineInterx = [px(closestLine) px(3)];
                        lineIntery = [py(closestLine) py(3)];
                    elseif closestLine ~= 100000
                        lineInterx = [px(closestLine) px(closestLine+1)];
                        lineIntery = [py(closestLine) py(closestLine+1)];
                    end
                    if closestLine == 100000 %no intersection found inside the polygon 
                        startPoint = beacon;
                     elseif inpolygon(x_inter(closestLine), y_inter(closestLine), line1x, line1y) && (x_inter(closestLine) > min(lineInterx)) && (x_inter(closestLine) < max(lineInterx)) && (y_inter(closestLine) > min(lineIntery)) && (y_inter(closestLine) < max(lineIntery)) %proper intersection
                        pathTempX(pathPosition) = x_inter(closestLine);
                        pathTempY(pathPosition) = y_inter(closestLine);
                        pathPosition = pathPosition + 1;
                        %calculate perpendicular line
                        perpenSlope = -1/slope2(closestLine);
                        perpenB = beacon(2) - (perpenSlope * beacon(1));
                        xPerpen = -100;
                        yPerpen = (perpenSlope*xPerpen) + perpenB;
                        perpenLinex = [beacon(1) xPerpen];
                        perpenLiney = [beacon(2) yPerpen];
                        
                        %calculate intersection of perpendicular line and intersecting line
                        perFit1 = polyfit(perpenLinex, perpenLiney, 1);
                        perFit2 = polyfit(lineInterx, lineIntery, 1);
                        normalX(count) = round(fzero(@(x) polyval(perFit1-perFit2, x), 3, options), 14);
                        normalY(count) = round(polyval(perFit1, normalX(count)), 14);
                        midPointX = (x_inter(closestLine) + startPoint(1)) / 2;
                        midPointY = (y_inter(closestLine) + startPoint(2)) / 2;
                        if inpolygon(midPointX, midPointY, px, py) == 0
                            pathTempX(pathPosition-1) = 0;
                            pathTempY(pathPosition-1) = 0;
                            endPoint = [startPoint(1) startPoint(2)];
                            startPoint = beacon;
                        elseif (normalX(count) > min(lineInterx)) && (normalX(count) < max(lineInterx)) && (normalY(count) > min(lineIntery)) && (normalY(count) < max(lineIntery))
                            startPoint = beacon;
                            endPoint = [normalX(count) normalY(count)];
                        elseif inpolygon(normalX(count), normalY(count), px, py) == 0
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 < distNorm2
                                startPoint = [px(closestLine) py(closestLine)];
                            else
                                startPoint = [px(closestLine+1) py(closestLine+1)];
                            end
                        else
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 > distNorm2
                                startPoint = [lineInterx(2) lineIntery(2)];
                                endPoint = beacon;
                            elseif distNorm1 < distNorm2
                                startPoint = [lineInterx(1) lineIntery(1)];
                                endPoint = beacon;
                            else
                                startPoint = beacon;
                                endPoint = [normalX(count) normalY(count)];
                            end
                        end
                    else
                        if pathTempX == 1
                            startPoint = beacon;
                            endPoint = beacon;
                        else
                            startPoint = beacon;
                            endPoint = beacon;
                        end
                    end
                    count = count + 1;
                end
                pathTempX(numNodes*2) = endPoint(1);
                pathTempY(numNodes*2) = endPoint(2);
                pathTempX = pathTempX(pathTempX ~= 0);
                pathTempY = pathTempY(pathTempY ~= 0);
                pathBAT = [pathTempX pathTempY];
                if endPoint(1) ~= beacon(1) && endPoint(2) ~= beacon(2)
                    stopPoint = endPoint;
                end
                for i = 1 : length(pathTempX)
                    if i+1 <= length(pathTempX)
                        tempDist = sqrt((pathTempX(i) - pathTempX(i+1))^2+(pathTempY(i) - pathTempY(i+1))^2);
                        lengthBATPath = lengthBATPath + tempDist;
                    end
                end
               
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                plot(px(3 : numNodes), py(3 : numNodes), 'k', 'LineWidth', 2); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                plot(lastLineX, lastLineY, 'k', 'LineWidth', 2); hold on;
                p = plot(G, 'XData', px, 'YData', py, 'EdgeColor', 'w', 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', [], 'Color', [0.95, 0.95, 1]);
                set(changeBeacon, 'Enable', 'on');
                set(changeStart, 'Enable', 'on');
                editStart = 0;
                editBeacon = 0;
                algorithmButton = uicontrol('Style', 'popup', 'String', {'Choose an Algorithm', 'B.A.T.', 'S.P.', 'Create Path', 'All Paths'}, 'Position',[20 490 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'HandleVisibility','off', 'Callback', @findPath, 'Enable', 'on');
                
            case 'Polygon2' %create the second polygon
                cla reset;
                clearvars -global;
                G = 0;
                endPoint = [-1 -1];
                count = 1;
                stopPoint = [-1 -1];
                lengthBATPath = 0;
                lastLineX = [0 0];
                lastLineY = [0 0];
                startNode = 0;
                endNode = 0;
                p = 0;
                numNodes = 0;
                nLabel = {};
                if editStart == 0 && editBeacon == 0
                    px = [4.4 0.7 5 4.3 3.2 2.5 2.2 1.9 1.5 1.2 0.1 0.5 3.3 3.5];
                    py = [1 2.7 0.1 5 5 3.6 5 3.5 5 3.6 5 1.5 4.1 0.1];
                end
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon((line2x(1) + line2x(2))/2, (line2y(1) + line2y(2))/2, px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distanceToStart = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distanceToStart; 
                end
                
                startPoint = [px(1) py(1)];
                beacon = [px(2) py(2)];
                pathPosition = 1;
                pathTempX = zeros(numNodes*2);
                pathTempY = zeros(numNodes*2);
                distanceStartToBeacon = sqrt((startPoint(1) - beacon(1))^2+(startPoint(2) - beacon(2))^2);
                options = optimset('Display','off');
                while (startPoint(1) ~= beacon(1)) || (startPoint(2) ~= beacon(2))  
                    pathTempX(pathPosition) = startPoint(1);
                    pathTempY(pathPosition) = startPoint(2);
                    pathPosition = pathPosition + 1;
                    line1x = [startPoint(1) beacon(1)];
                    line1y = [startPoint(2) beacon(2)];
                    closestLine = 100000;
                    closestDist = 100000;
                    for i = 3 : numNodes
                        if (i+1) > numNodes
                            line2x = [px(i) px(3)];
                            line2y = [py(i) py(3)];
                            slope2(i) = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                        else
                            line2x = [px(i) px(i+1)];
                            line2y = [py(i) py(i+1)];
                            slope2(i) = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                        end
                        fit1 = polyfit(line1x, line1y, 1);
                        fit2 = polyfit(line2x, line2y, 1);
                        x_inter(i) = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                        y_inter = round(polyval(fit1, x_inter), 14);
                        if (x_inter(i) > min(line2x)) && (x_inter(i) < max(line2x)) && (y_inter(i) > min(line2y)) && (y_inter(i) < max(line2y))
                            distanceToStart = sqrt((x_inter(i) - startPoint(1))^2+(y_inter(i) - startPoint(2))^2);
                            distanceToBeacon = sqrt((x_inter(i) - beacon(1))^2+(y_inter(i) - beacon(2))^2);
                            if (distanceToStart < closestDist) && (distanceToBeacon < distanceStartToBeacon) && inpolygon(x_inter(i), y_inter(i), line1x, line1y)
                                closestLine = i;
                                closestDist = distanceToStart;
                            end
                        end
                    end
                    %find intersecting line with perpendicular
                    if closestLine ~= 100000 && (closestLine + 1) > numNodes
                        lineInterx = [px(closestLine) px(3)];
                        lineIntery = [py(closestLine) py(3)];
                    elseif closestLine ~= 100000
                        lineInterx = [px(closestLine) px(closestLine+1)];
                        lineIntery = [py(closestLine) py(closestLine+1)];
                    end
                    if closestLine == 100000 %no intersection found inside the polygon 
                        startPoint = beacon;
                    elseif inpolygon(x_inter(closestLine), y_inter(closestLine), line1x, line1y) && (x_inter(closestLine) > min(lineInterx)) && (x_inter(closestLine) < max(lineInterx)) && (y_inter(closestLine) > min(lineIntery)) && (y_inter(closestLine) < max(lineIntery)) %proper intersection
                        pathTempX(pathPosition) = x_inter(closestLine);
                        pathTempY(pathPosition) = y_inter(closestLine);
                        pathPosition = pathPosition + 1;
                        %calculate perpendicular line
                        perpenSlope = -1/slope2(closestLine);
                        perpenB = beacon(2) - (perpenSlope * beacon(1));
                        xPerpen = -100;
                        yPerpen = (perpenSlope*xPerpen) + perpenB;
                        perpenLinex = [beacon(1) xPerpen];
                        perpenLiney = [beacon(2) yPerpen];
                        
                        %calculate intersection of perpendicular line and intersecting line
                        perFit1 = polyfit(perpenLinex, perpenLiney, 1);
                        perFit2 = polyfit(lineInterx, lineIntery, 1);
                        normalX(count) = round(fzero(@(x) polyval(perFit1-perFit2, x), 3, options), 14);
                        normalY(count) = round(polyval(perFit1, normalX(count)), 14);
                        midPointX = (x_inter(closestLine) + startPoint(1)) / 2;
                        midPointY = (y_inter(closestLine) + startPoint(2)) / 2;
                        if inpolygon(midPointX, midPointY, px, py) == 0
                            pathTempX(pathPosition-1) = 0;
                            pathTempY(pathPosition-1) = 0;
                            endPoint = [startPoint(1) startPoint(2)];
                            startPoint = beacon;
                        elseif (normalX(count) >= min(lineInterx)) && (normalX(count) <= max(lineInterx)) && (normalY(count) >= min(lineIntery)) && (normalY(count) <= max(lineIntery))
                            startPoint = beacon;
                            endPoint = [normalX(count) normalY(count)];
                        elseif inpolygon(normalX(count), normalY(count), px, py) == 0
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 < distNorm2
                                startPoint = [px(closestLine) py(closestLine)];
                            else
                                startPoint = [px(closestLine+1) py(closestLine+1)];
                            end
                        else
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 > distNorm2
                                startPoint = [lineInterx(2) lineIntery(2)];
                                endPoint = beacon;
                            elseif distNorm1 < distNorm2
                                startPoint = [lineInterx(1) lineIntery(1)];
                                endPoint = beacon;
                            else
                                startPoint = beacon;
                                endPoint = [normalX(count) normalY(count)];
                            end
                        end
                    else
                        if pathTempX == 1
                            startPoint = beacon;
                            endPoint = beacon;
                        else
                            startPoint = beacon;
                            endPoint = beacon;
                        end
                    end
                    count = count + 1;
                end
                pathTempX(numNodes*2) = endPoint(1);
                pathTempY(numNodes*2) = endPoint(2);
                pathTempX = pathTempX(pathTempX ~= 0);
                pathTempY = pathTempY(pathTempY ~= 0);
                pathBAT = [pathTempX pathTempY];
                if endPoint(1) ~= beacon(1) && endPoint(2) ~= beacon(2)
                    stopPoint = endPoint;
                end
                for i = 1 : length(pathTempX)
                    if i+1 <= length(pathTempX)
                        tempDist = sqrt((pathTempX(i) - pathTempX(i+1))^2+(pathTempY(i) - pathTempY(i+1))^2);
                        lengthBATPath = lengthBATPath + tempDist;
                    end
                end
               
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                plot(px(3 : numNodes), py(3 : numNodes), 'k', 'LineWidth', 2); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                plot(lastLineX, lastLineY, 'k', 'LineWidth', 2); hold on;
                p = plot(G, 'XData', px, 'YData', py, 'EdgeColor', 'w', 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(changeBeacon, 'Enable', 'on');
                set(changeStart, 'Enable', 'on');
                editStart = 0;
                editBeacon = 0;
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', [], 'Color', [0.95, 0.95, 1]);
                algorithmButton = uicontrol('Style', 'popup', 'String', {'Choose an Algorithm', 'B.A.T.', 'S.P.', 'Create Path', 'All Paths'}, 'Position',[20 490 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'HandleVisibility','off', 'Callback', @findPath, 'Enable', 'on');
                
            case 'Polygon3' %create the third polygon
                cla reset;
                clearvars -global;
                G = 0;
                stopPoint = [-1 -1];
                endPoint = [-1 -1];
                count = 1;
                lengthBATPath = 0;
                lastLineX = [0 0];
                lastLineY = [0 0];
                startNode = 0;
                endNode = 0;
                p = 0;
                numNodes = 0;
                nLabel = {};
                if editStart == 0 && editBeacon == 0
                    px = [6.2 1.2 7 5.5 3 2.1 1.3 1 1.1 1.5 2 2.3 3.1 4.5 4];
                    py = [0.3 0.8 0.1 4 3 3.2 2.5 3 0.1 0.1 1.5 0.7 1.3 1.7 0.1];
                end
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon((line2x(1) + line2x(2))/2, (line2y(1) + line2y(2))/2, px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distanceToStart = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distanceToStart; 
                end
                
                startPoint = [px(1) py(1)];
                beacon = [px(2) py(2)];
                pathPosition = 1;
                pathTempX = zeros(numNodes*2);
                pathTempY = zeros(numNodes*2);
                distanceStartToBeacon = sqrt((startPoint(1) - beacon(1))^2+(startPoint(2) - beacon(2))^2);
                options = optimset('Display','off');
                while (startPoint(1) ~= beacon(1)) || (startPoint(2) ~= beacon(2))  
                    pathTempX(pathPosition) = startPoint(1);
                    pathTempY(pathPosition) = startPoint(2);
                    pathPosition = pathPosition + 1;
                    line1x = [startPoint(1) beacon(1)];
                    line1y = [startPoint(2) beacon(2)];
                    closestLine = 100000;
                    closestDist = 100000;
                    for i = 3 : numNodes
                        if (i+1) > numNodes
                            line2x = [px(i) px(3)];
                            line2y = [py(i) py(3)];
                            slope2(i) = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                        else
                            line2x = [px(i) px(i+1)];
                            line2y = [py(i) py(i+1)];
                            slope2(i) = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                        end
                        fit1 = polyfit(line1x, line1y, 1);
                        fit2 = polyfit(line2x, line2y, 1);
                        x_inter(i) = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                        y_inter = round(polyval(fit1, x_inter), 14);
                        if (x_inter(i) > min(line2x)) && (x_inter(i) < max(line2x)) && (y_inter(i) > min(line2y)) && (y_inter(i) < max(line2y))
                            distanceToStart = sqrt((x_inter(i) - startPoint(1))^2+(y_inter(i) - startPoint(2))^2);
                            distanceToBeacon = sqrt((x_inter(i) - beacon(1))^2+(y_inter(i) - beacon(2))^2);
                            if (distanceToStart < closestDist) && (distanceToBeacon < distanceStartToBeacon) && inpolygon(x_inter(i), y_inter(i), line1x, line1y)
                                closestLine = i;
                                closestDist = distanceToStart;
                            end
                        end
                    end
                    %find intersecting line with perpendicular
                    if closestLine ~= 100000 && (closestLine + 1) > numNodes
                        lineInterx = [px(closestLine) px(3)];
                        lineIntery = [py(closestLine) py(3)];
                    elseif closestLine ~= 100000
                        lineInterx = [px(closestLine) px(closestLine+1)];
                        lineIntery = [py(closestLine) py(closestLine+1)];
                    end
                    if closestLine == 100000 %no intersection found inside the polygon 
                        startPoint = beacon;
                    elseif inpolygon(x_inter(closestLine), y_inter(closestLine), line1x, line1y) && (x_inter(closestLine) > min(lineInterx)) && (x_inter(closestLine) < max(lineInterx)) && (y_inter(closestLine) > min(lineIntery)) && (y_inter(closestLine) < max(lineIntery)) %proper intersection
                        pathTempX(pathPosition) = x_inter(closestLine);
                        pathTempY(pathPosition) = y_inter(closestLine);
                        pathPosition = pathPosition + 1;
                        %calculate perpendicular line
                        perpenSlope = -1/slope2(closestLine);
                        perpenB = beacon(2) - (perpenSlope * beacon(1));
                        xPerpen = -100;
                        yPerpen = (perpenSlope*xPerpen) + perpenB;
                        perpenLinex = [beacon(1) xPerpen];
                        perpenLiney = [beacon(2) yPerpen];
                        
                        %calculate intersection of perpendicular line and intersecting line
                        perFit1 = polyfit(perpenLinex, perpenLiney, 1);
                        perFit2 = polyfit(lineInterx, lineIntery, 1);
                        normalX(count) = round(fzero(@(x) polyval(perFit1-perFit2, x), 3, options), 14);
                        normalY(count) = round(polyval(perFit1, normalX(count)), 14);
                        midPointX = (x_inter(closestLine) + startPoint(1)) / 2;
                        midPointY = (y_inter(closestLine) + startPoint(2)) / 2;
                        if inpolygon(midPointX, midPointY, px, py) == 0
                            pathTempX(pathPosition-1) = 0;
                            pathTempY(pathPosition-1) = 0;
                            endPoint = [startPoint(1) startPoint(2)];
                            startPoint = beacon;
                        elseif (normalX(count) > min(lineInterx)) && (normalX(count) < max(lineInterx)) && (normalY(count) > min(lineIntery)) && (normalY(count) < max(lineIntery))
                            startPoint = beacon;
                            endPoint = [normalX(count) normalY(count)];
                        elseif inpolygon(normalX(count), normalY(count), px, py) == 0
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 < distNorm2
                                startPoint = [px(closestLine) py(closestLine)];
                            else
                                startPoint = [px(closestLine+1) py(closestLine+1)];
                            end
                        else
                            distNorm1 = sqrt((lineInterx(1) - normalX(count))^2+(lineIntery(1) - normalY(count))^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX(count))^2+(lineIntery(2) - normalY(count))^2);
                            if distNorm1 > distNorm2
                                startPoint = [lineInterx(2) lineIntery(2)];
                                endPoint = beacon;
                            elseif distNorm1 < distNorm2
                                startPoint = [lineInterx(1) lineIntery(1)];
                                endPoint = beacon;
                            else
                                startPoint = beacon;
                                endPoint = [normalX(count) normalY(count)];
                            end
                        end
                    else
                        if pathTempX == 1
                            startPoint = beacon;
                            endPoint = beacon;
                        else
                            startPoint = beacon;
                            endPoint = beacon;
                        end
                    end
                    count = count + 1;
                end
                pathTempX(numNodes*2) = endPoint(1);
                pathTempY(numNodes*2) = endPoint(2);
                pathTempX = pathTempX(pathTempX ~= 0);
                pathTempY = pathTempY(pathTempY ~= 0);
                pathBAT = [pathTempX pathTempY];
                if endPoint(1) ~= beacon(1) && endPoint(2) ~= beacon(2)
                    stopPoint = endPoint;
                end
                for i = 1 : length(pathTempX)
                    if i+1 <= length(pathTempX)
                        tempDist = sqrt((pathTempX(i) - pathTempX(i+1))^2+(pathTempY(i) - pathTempY(i+1))^2);
                        lengthBATPath = lengthBATPath + tempDist;
                    end
                end
               
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                plot(px(3 : numNodes), py(3 : numNodes), 'k', 'LineWidth', 2); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                plot(lastLineX, lastLineY, 'k', 'LineWidth', 2); hold on;
                p = plot(G, 'XData', px, 'YData', py, 'EdgeColor', 'w', 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(changeBeacon, 'Enable', 'on');
                set(changeStart, 'Enable', 'on');
                editStart = 0;
                editBeacon = 0;
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', [], 'Color', [0.95, 0.95, 1]);
                algorithmButton = uicontrol('Style', 'popup', 'String', {'Choose an Algorithm', 'B.A.T.', 'S.P.', 'Create Path', 'All Paths'}, 'Position',[20 490 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'HandleVisibility','off', 'Callback', @findPath, 'Enable', 'on');
        end
    end
    
    function findPath(source, ~)
        set(changeBeacon, 'Enable', 'off');
        set(changeStart, 'Enable', 'off');
        set(showNorm, 'Enable', 'off');
        if diff ~= 0
            delete(diffArea);
        end
        lengthSPPath = 0;
        normalX = 0;
        normalY = 0;
        createPath = 0;
        countCreatePath = 1;
        lengthCreatePath = 0;
        stopCreate = 0;
        currX = -1;
        currY = -1;
        str = get(source, 'String');
        val = get(source,'Value');
        cla reset
        plot(px(3 : numNodes), py(3 : numNodes), 'k', 'LineWidth', 2); hold on;
        plot(lastLineX, lastLineY, 'k', 'LineWidth', 2); hold on;
        p = plot(G, 'w', 'XData', px, 'YData', py, 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', [], 'Color', [0.95, 0.95, 1]);
        highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
        highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
        set(createPolygon, 'Enable', 'off');
        switch str{val};
            case 'S.P.' 
                pathSP = shortestpath(G,pointNode,beaconNode);
                for i = 1 : length(pathSP)
                    if i+1 <= length(pathSP)
                        tempDist = sqrt((px(pathSP(i)) - px(pathSP(i+1)))^2+(py(pathSP(i)) - py(pathSP(i+1)))^2);
                        lengthSPPath = lengthSPPath + tempDist;
                    end
                end
                startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Callback', {@startPath, pathSP, 0, 0}, 'Enable', 'on'); 
            case 'B.A.T.'
                startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Callback', {@startPath, pathBAT, 0, 0}, 'Enable', 'on'); 
            case 'Create Path'
                for i = 1 : numNodes
                    valX(i) = px(i);
                    valY(i) = py(i);
                    plot(valX(i), valY(i), '*k', 'ButtonDownFcn', @createLines); hold on;
                end
                startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Callback', {@startPath, createPath, 0, 0}, 'Enable', 'on'); 
            case 'All Paths'
                pathSP = shortestpath(G,pointNode,beaconNode);
                for i = 1 : length(pathSP)
                    if i+1 <= length(pathSP)
                        tempDist = sqrt((px(pathSP(i)) - px(pathSP(i+1)))^2+(py(pathSP(i)) - py(pathSP(i+1)))^2);
                        lengthSPPath = lengthSPPath + tempDist;
                    end
                end
                for i = 1 : numNodes
                    valX(i) = px(i);
                    valY(i) = py(i);
                    plot(valX(i), valY(i), '*k', 'ButtonDownFcn', @createLines); hold on;
                end
                startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Callback', {@startPath, pathSP, pathBAT, createPath}, 'Enable', 'on'); 
        end
    end
    
    function resetSim(~, ~)
        delete(algorithmButton);
        delete(startButton);
        delete(changeBeacon);
        delete(changeStart);
        delete(createPolygon);
        delete(showNorm);
        cla reset;
        clearvars -global;
        if diff ~= 0
            delete(diffArea);
        end
        px = 0;
        diff = 0;
        py = 0;
        G = 0;
        editStart = 0;
        editBeacon = 0;
        stopPoint = [-1 -1];
        stopCreate = 0;
        lastLineX = [0 0];
        lastLineY = [0 0];
        startNode = 0;
        endNode = 0;
        p = 0;
        numNodes = 0;
        createPath = 0;
        countCreatePath = 1;
        lengthCreatePath = 0;
        lengthBATPath = 0;
        lengthSPPath = 0;
        currX = -1;
        currY = -1;
        showNorm = uicontrol('Style', 'radiobutton', 'String', 'Show Normals', 'Position', [600 620 100 20], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [1, 1, 1], 'Callback', @showNormals, 'Enable', 'off');
        createPolygon = uicontrol('Style', 'pushbutton', 'String', 'Create Polygon', 'Position', [24 350 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @newPolygon, 'Enable', 'on'); 
        changeBeacon = uicontrol('Style', 'pushbutton', 'String', 'Change Beacon', 'Position', [24 460 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @setBeacon, 'Enable', 'off'); 
        changeStart = uicontrol('Style', 'pushbutton', 'String', 'Change Start Point', 'Position', [24 400 120 30], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @setStart, 'Enable', 'off'); 
        algorithmButton = uicontrol('Style', 'popup', 'String', {'Choose an Algorithm', 'B.A.T.', 'S.P.', 'Create Path', 'All Paths'}, 'Position',[20 490 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 11, 'BackgroundColor', [0.95, 0.95, 1], 'HandleVisibility','off', 'Enable', 'off');
        startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [400 35 110 40], 'ForegroundColor', [0.1, 0.4, 1], 'BackgroundColor', [0.95, 0.95, 1], 'FontSize', 20, 'FontWeight', 'bold', 'Enable', 'off'); 
        uicontrol('Style', 'text', 'String', 'DISTANCE TO BEACON:', 'Position', [10 120 140 120], 'Foreground', [0.1, 0.4, 1], 'FontSize', 12, 'BackgroundColor', [0.9 0.9 0.9]);
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', [], 'Color', [0.95, 0.95, 1]);
    end

    function startPath(~, ~, pathType, pathType2, ~)
        [row, col] = size(pathType);
        if col ~= 2
            if col ~= 1
                highlight(p, pathType, 'EdgeColor', [1 .5 0], 'NodeColor', [1 .5 0], 'LineWidth', 6);
                str1 = ['S.P. TO BEACON: ', num2str(lengthSPPath)];
                uicontrol('Style', 'text', 'String', str1, 'Position', [10 120 140 120], 'Foreground', [1 .5 0], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
            else
                [rowC, ~] = size(createPath);
                for i = 1 : rowC
                    if (i+1) <= rowC
                        linex = [createPath(i,1) createPath(i+1,1)];
                        liney = [createPath(i,2) createPath(i+1,2)];
                        if (i+1) <= rowC
                            tempDistC = sqrt((createPath(i, 1) - createPath(i+1, 1))^2+(createPath(i, 2) - createPath(i+1, 2))^2);
                            lengthCreatePath = lengthCreatePath + tempDistC;
                        end
                        plot(linex, liney, 'g', 'LineWidth', 3); hold on;
                    end
                end
                hold off;
                str3 = ['PATH TO BEACON: ', num2str(lengthCreatePath)];
                uicontrol('Style', 'text', 'String', str3, 'Position', [10 120 140 120], 'Foreground', [0.1, 1, 0.4], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
                highlight(p, pointNode, 'NodeColor', 'g', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'g', 'MarkerSize', 13);
            end
        else
            for i = 1 : row
                if (i+1) <= row
                    linex = [pathType(i,1) pathType(i+1,1)];
                    liney = [pathType(i,2) pathType(i+1,2)];
                    plot(linex, liney, 'b', 'LineWidth', 3); hold on;
                end
            end
            if stopPoint(1) ~= -1 && stopPoint(2) ~=-1
                plot(stopPoint(1), stopPoint(2), '*r', 'MarkerSize', 23); hold on;
            end
            hold off;
            str2 = ['B.A.T. TO BEACON: ', num2str(lengthBATPath)];
            uicontrol('Style', 'text', 'String', str2, 'Position', [10 120 140 120], 'Foreground', [0.1, 0.4, 1], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
            highlight(p, pointNode, 'NodeColor', 'b', 'MarkerSize', 10);
            highlight(p, beaconNode, 'NodeColor', 'b', 'MarkerSize', 13);
        end
        [row2, ~] = size(pathType2);
        [rowC, ~] = size(createPath);
        if pathType2 ~= 0
            for i = 1 : row2
                if (i+1) <= row2
                    linex = [pathType2(i,1) pathType2(i+1,1)];
                    liney = [pathType2(i,2) pathType2(i+1,2)];
                    plot(linex, liney, 'b', 'LineWidth', 3); hold on;
                end
            end
            if stopPoint(1) ~= -1 && stopPoint(2) ~=-1
                plot(stopPoint(1), stopPoint(2), '*r', 'MarkerSize', 23); hold on;
            end
            for i = 1 : rowC
                if (i+1) <= rowC
                    linex = [createPath(i,1) createPath(i+1,1)];
                    liney = [createPath(i,2) createPath(i+1,2)];
                    if (i+1) <= rowC
                        tempDistC = sqrt((createPath(i, 1) - createPath(i+1, 1))^2+(createPath(i, 2) - createPath(i+1, 2))^2);
                        lengthCreatePath = lengthCreatePath + tempDistC;
                    end
                    plot(linex, liney, 'g', 'LineWidth', 3); hold on;
                end
            end
            str1 = ['S.P. TO BEACON: ', num2str(lengthSPPath)];
            str2 = ['B.A.T. TO BEACON: ', num2str(lengthBATPath)];
            str3 = ['PATH TO BEACON: ', num2str(lengthCreatePath)];
            diff = lengthBATPath - lengthSPPath;
            strDiff = ['Difference Between B.A.T. and S.P. : ', num2str(diff)];
            uicontrol('Style', 'text', 'String', str1, 'Position', [10 120 140 120], 'Foreground', [1 0.5 0], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
            uicontrol('Style', 'text', 'String', str2, 'Position', [10 120 140 80], 'Foreground', [0.1, 0.4, 1], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
            uicontrol('Style', 'text', 'String', str3, 'Position', [10 120 140 40], 'Foreground', [0.1, 1, 0.4], 'FontSize', 13, 'BackgroundColor', [0.9 0.9 0.9]);
            if diff < sqrt(2) && diff >= 0
                diffArea = uicontrol('Style', 'text', 'String', strDiff, 'Position', [10 260 140 70], 'Foreground', 'm', 'FontSize', 13, 'BackgroundColor', [1 1 1]);
            elseif diff >= 0
                diffArea = uicontrol('Style', 'text', 'String', strDiff, 'Position', [10 260 140 70], 'Foreground', 'r', 'FontSize', 13, 'BackgroundColor', [1 1 1]);
            end
            highlight(p, pointNode, 'NodeColor', 'y', 'MarkerSize', 10);
            highlight(p, beaconNode, 'NodeColor', 'y', 'MarkerSize', 13);
        end
        set(startButton, 'Enable', 'off');
    end

    function backHome(~, ~)
        delete(home)
        home = figure('Position', [300,400,800,800], 'Name', 'Beacon Attraction Trajectory Simulation', 'NumberTitle', 'off', 'menubar', 'none', 'Color', 'w'); %Visible off while adding components, Size of window, Name of figure, Turn off the figure number
        logo = imread('BATSLogo.png');
        axes('position',[.31 .5 0.4 0.4]);
        imagesc(logo);
        enter = uicontrol('Style', 'pushbutton', 'String', 'Enter', 'Position', [343 70 130 50], 'ForegroundColor', [0.1, 0.4, 1], 'FontSize', 18, 'FontWeight', 'bold', 'BackgroundColor', [0.95, 0.95, 1], 'Callback', @mainFigure); 
        welcome = uicontrol('Style', 'text', 'String', 'Welcome to B.A.T.S.', 'Position', [210 260 400 50], 'FontSize', 40, 'FontWeight', 'bold', 'BackgroundColor', 'w');
        info = uicontrol('Style', 'text', 'String', 'B.A.T.S. allows users to simulate the beacon attraction trajectory on simple polygons and compare that trajectory to the shortest path.', 'ForegroundColor', [0.1, 0.4, 1], 'Position', [210 150 400 100], 'FontSize', 15, 'BackgroundColor', 'w');
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
    end
    
%doesn't let you click on vertex already clicked on
    function createLines(src, ~)
        while countCreatePath == 1
            if src.XData == px(pointNode) && src.YData == py(pointNode)
                currX = src.XData;
                currY = src.YData;
                createPath(countCreatePath, 1) = currX;
                createPath(countCreatePath, 2) = currY;
                countCreatePath = countCreatePath + 1;
            else
                disp('You must start from the start point');
                return
            end
        end
        if stopCreate == 0
            if countCreatePath > 1
                if src.XData == px(beaconNode) && src.YData == py(beaconNode)
                    plot([src.XData currX], [src.YData currY], 'm');
                    currX = src.XData;
                    currY = src.YData;
                    createPath(countCreatePath, 1) = currX;
                    createPath(countCreatePath, 2) = currY;
                    stopCreate = 1;
                else
                    for i = 1 : length(startNode)
                        if (currX == px(startNode(i)) && currY == py(startNode(i)) && src.XData == px(endNode(i)) && src.YData == py(endNode(i))) || (currX == px(endNode(i)) && currY == py(endNode(i)) && src.XData == px(startNode(i)) && src.YData == py(startNode(i)))
                            plot([src.XData currX], [src.YData currY], 'm');
                            currX = src.XData;
                            currY = src.YData;
                            createPath(countCreatePath, 1) = currX;
                            createPath(countCreatePath, 2) = currY;
                            countCreatePath = countCreatePath + 1;
                        end 
                    end
                end
            end
        end
    end
    function setStart(~, ~)
        [x, y] = ginput(1);
        if inpolygon(x, y, px(3:numNodes), py(3:numNodes))
            px(pointNode) = x;
            py(pointNode) = y;
            editStart = 1;
            changePolygon(polygonSource, 1);
        else
            disp('Start Point is outside of polygon.');
            return
        end
    end

    function setBeacon(~, ~)
        [x, y] = ginput(1);
        if inpolygon(x, y, px(3:numNodes), py(3:numNodes))
            px(beaconNode) = x;
            py(beaconNode) = y;
            editBeacon = 1;
            changePolygon(polygonSource, 1);
        else
            disp('Beacon is outside of polygon.');
            return
        end
    end

    function newPolygon(src, ~)
        
    end

    function showNormals(src, ~)
        if src.Value == 1
            for i = 1 : length(normalX)
                plot(normalX(i), normalY(i), 'ro'); hold on;
            end
        else
            for i = 1 : length(normalX)
                plot(normalX(i), normalY(i), 'wo'); hold on;
            end
        end
    end
end