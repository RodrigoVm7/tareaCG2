close all;
clear all;
img = imread('figura8.png');
i=Tarea2(img)
ee = ones(3,3);
i.erosionar(ee)
figure, imagesc(i.obtenerImagenOriginal)
figure, imagesc(i.obtenerImagenProcesada)