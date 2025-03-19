<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\User;

class UserController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        // Validate the incoming request
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        // Create a new user
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
        ]);

        // Return a JSON response
        return response()->json([
            'message' => 'User registered successfully!',
            'data' => $user,
        ], 201);
    }

    public function getUser(Request $request): JsonResponse
    {
        $token = $request->bearerToken();
        return response()->json([
            'status' => 'success',
            'user' => $request->user(),
            'token' => $token
        ]);
    }
}
