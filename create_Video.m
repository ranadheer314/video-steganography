clc;
clear all;
close all;
warning('off','all');
% % Get the file
% folder = dir('View_001');
% for i = 3:length(folder)
%     f = folder(i).name;
%     images{i,:} = imread(fullfile('View_001\',f));
% end
% % create the video writer with 1 fps
% a = VideoWriter('myVideo.avi');
% a.FrameRate = 3;
% % open the video writer
% open(a);
% % write the frames to the video
% for u = 3:length(images)
%     % convert the image to a frame
%     frame1 = im2frame(images{u});
%     writeVideo(a, frame1);
% end
% % close the writer object
% close(a);
% %  implay('myVideo.avi')
% % % mot_track();
addpath('subfile\');

reader = vision.VideoFileReader('myStego.avi');
% obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
% obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 415, 'MinimumBackgroundRatio', 0.7);
blob = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea',400);
vid_frame = vision.VideoPlayer('Position', [256,256,256,256]);
vid_mask = vision.VideoPlayer('Position', [256,256,256,256]);
ii = 1;
  while ~isDone(reader)
    frame  = reader.step();
    fgMask = detector.step(frame);
    mask = imopen(fgMask, strel('rectangle', [3,3]));
    mask = imclose(mask, strel('rectangle', [15, 15]));
    mask = imfill(mask, 'holes');
    [~,centroid,bbox] = blob.step(fgMask);
    arr = [];
    arr = bbox;
    a1{ii,1} = arr;
    ii = ii+1;
    [~,centroids,bboxs] = blob.step(mask);
    % draw bounding boxes around cars
    out = insertShape(frame, 'Rectangle', bbox, 'Color', 'blue');
    out1 = insertShape(double(mask),'Rectangle',bboxs,'Color','green');
    % view results in the video player
    step(vid_frame, out); 
    step(vid_mask,out1);
% % Background Subtraction
%     ou = out - out1;
  end
  release(vid_frame);
  release(vid_mask);
  release(reader);

