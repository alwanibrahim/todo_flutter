<?php

namespace App\Http\Controllers;

use App\Models\Label;
use Illuminate\Http\Request;

class LabelController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Ambil labels milik user yang sedang login
        $labels = auth()->user()->labels()->get();
        return response()->json($labels);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        // This method is not needed for API resources
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Validasi input
        $request->validate([
            'name' => 'required|string|max:255|unique:labels,name,NULL,id,user_id,' . auth()->id(),
        ]);

        // Simpan label ke database
        $label = auth()->user()->labels()->create([
            'name' => $request->name,
        ]);

        // Berikan response JSON
        return response()->json([
            'message' => 'Label created successfully!',
            'data' => $label,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Label $label)
    {
        return response()->json($label);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Label $label)
    {
        return response()->json($label);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Label $label)
    {
        // Validasi input
        $request->validate([
            'name' => 'required|string|max:255|unique:labels,name,' . $label->id . ',id,user_id,' . auth()->id(),
        ]);

        $label->update($request->all());
        return response()->json($label);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Label $label)
    {
        $label->delete();
        return response()->json(null, 204);
    }
}
