<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\TodoController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\LabelController;


Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/register', [AuthController::class, 'register']); //* ini untuk register
Route::post('/login', [AuthController::class, 'login']); //*ini untuk login
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum'); //* ini untuk logout
Route::middleware('auth:sanctum')->get('/user', [UserController::class, 'getUser']); //*ini untuk mengembil data user yg sedang login

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('todos', TodoController::class);
    Route::apiResource('categories', CategoryController::class);
    Route::apiResource('labels', LabelController::class);

});
