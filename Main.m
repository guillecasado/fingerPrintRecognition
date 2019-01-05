
f = figure('Name', 'Programa de matching per empremtes dactilars','Visible','off', 'NumberTitle', 'off');
popup = uicontrol('Style', 'popup',...
           'String', {'None','Albert_1','Albert_2','Amadeu_1','Amadeu_2','Elena_1','Elena_2','Elena_3', 'Guille_1','Guille_2','Guille_3','Guille_4','Teresa_1', 'Teresa_2','Teresa_4'},...
           'Position', [20 340 100 50],...
           'Tag','popup_captured',...
           'UserData',struct('Image',''),...
           'Callback', @setList);
popup2 = uicontrol('Style', 'popup',...
           'String', {'None','Albert_1','Albert_2','Amadeu_1','Amadeu_2','Elena_1','Elena_2','Elena_3', 'Guille_1','Guille_2','Guille_3','Guille_4','Teresa_1', 'Teresa_2','Teresa_4'},...
           'Position', [440 340 100 50],...
           'Tag','popup_database',...
           'UserData', struct('Image',''),...
           'Callback', @setList2);
runButton = uicontrol('Style', 'pushbutton','String','Comparar les empremtes!',...
           'Position', [200 360 150 50],...
           'Callback', @startMatching);
       
txtInformation = uicontrol('Style','text',...
     'Position',[220 20 160 75],...
     'FontSize',12.5,...
     'FontWeight','Bold',...
     'Tag','text_for_information',...
     'String','Selecciona dues imatges i pitja el boto per comparar les imatges');
       
f.Visible = 'on';

function startMatching(source, event)
popup_1 = findobj('Tag','popup_captured');
popup_2 = findobj('Tag','popup_database');
pathCapturedImage = sprintf('./DB1_B/%s.tif', popup_1.UserData.Image);
pathDataBaseImage = sprintf('./DB1_B/%s.tif', popup_2.UserData.Image);
if(strcmp(popup_1.UserData.Image,'')|| strcmp(popup_2.UserData.Image,'') || strcmp(popup_1.UserData.Image,'None')|| strcmp(popup_2.UserData.Image,'None'))
    f = msgbox('Per tal de poder fer el matching no poden haver cap parametre a "None"','Mala seleccio');
else
    txt_info = findobj('Tag', 'text_for_information');
    txt_info.String = 'Processant algorisme...';
    txt_info.ForegroundColor = 'black';
    
    %Tornar a carregar imatges
    im2 = imread(pathCapturedImage);
    subplot(1,2,1), subimage(im2)
    title('Imatge acabada de capturar')
    
    im1 = imread(pathDataBaseImage);
    subplot(1,2,2), subimage(im1)
    title('Imatge de la base de dades')

    %Getting and Preprocessing captured image
    [Ithin2,MinutaeMatrixComplex2] = ext_finger(im2,1);


    %Translating second image to match with the original one
    center2=findCenter(MinutaeMatrixComplex2);
    Ithin2=imageTranslation(center2,Ithin2);


    %Get Minutiaes from second image
    [Bifurcations2,Terminations2,BifCentr2,TermCentr2]=GetMinutaes(Ithin2);
    minMat_curr=[BifCentr2;TermCentr2];

    %Matching
    [minMat_templ,Ithin, BifCentr1, TermCentr1] = TemplateImageProcessing(pathDataBaseImage);
    n_min_templ=size(minMat_templ(:,1));
    n_min_curr=size(minMat_curr(:,1));
    c=matching(minMat_templ,minMat_curr,0.8*min(n_min_templ,n_min_curr));

    subplot(1,2,1), subimage(Ithin2)
    title('Imatge capturada processada')
    hold on
    plot(TermCentr2(:,1),TermCentr2(:,2),'ro')
    plot(BifCentr2(:,1),BifCentr2(:,2),'go')
    hold off
    
    subplot(1,2,2), subimage(Ithin)
    title('Imatge base de dades processada')
    hold on
    plot(TermCentr1(:,1),TermCentr1(:,2),'ro')
    plot(BifCentr1(:,1),BifCentr1(:,2),'go')
    hold off

    if(c)
        txt_info.String = 'Matching Correcte!!!';
        txt_info.ForegroundColor = [0.298,0.5686,0.2549];
    else
        txt_info.String = 'Matching Incorrecte...';
        txt_info.ForegroundColor = [0.6078,0.06667,0.1176];


    end
end


end

function setList(source,event)
    val = source.Value;
    images = source.String;
    newImage = images{val};
    source.UserData.Image = newImage;
    if(val ~= 1)
        im=imread(sprintf('./DB1_B/%s.tif', newImage));
        subplot(1,2,1), subimage(im)
        title('Imatge acabada de capturar')
    end 
    
end

function setList2(source,event)
    val = source.Value;
    images = source.String;
    newImage = images{val};
    source.UserData.Image = newImage;
    if(val ~= 1)
        im=imread(sprintf('./DB1_B/%s.tif', newImage));
        subplot(1,2,2), subimage(im) 
        title('Imatge de la base de dades')
    end 
    
end

