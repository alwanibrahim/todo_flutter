<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TodoController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Ambil todos milik user yang sedang login
        $todos = auth()->user()->todos()->with(['category', 'label'])->get();
        return response()->json($todos);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Validasi input
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'label_id' => 'required|exists:labels,id',
            'priority' => 'required|in:rendah,sedang,tinggi',
            'deadline' => 'required|date',
        ]);

        // Simpan ke database
        $todo = auth()->user()->todos()->create($request->all());

        return response()->json($todo, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Todo $todo)
    {
        return response()->json($todo);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Todo $todo)
    {
        // Pastikan todo milik user yang sedang login
        if ($todo->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Validasi input
        $request->validate([
            'title' => 'string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'exists:categories,id',
            'label_id' => 'exists:labels,id',
            'priority' => 'in:rendah,sedang,tinggi',
            'deadline' => 'date',
        ]);

        $todo->update($request->all());
        return response()->json($todo);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Todo $todo)
    {
        // Pastikan todo milik user yang sedang login
        if ($todo->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $todo->delete();
        return response()->json(null, 204);
    }
}
