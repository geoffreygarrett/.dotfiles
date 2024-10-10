{ config, pkgs, ... }:

let
  cudaPackages = pkgs.cudaPackages_11_8; # Adjust this to the CUDA version you want to use

  llama2_api_script = pkgs.writeText "llama2_api.py" ''
    import os
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    from transformers import AutoTokenizer, AutoModelForCausalLM
    import torch

    app = FastAPI()

    # Load the Llama 2 model and tokenizer
    model_name = "meta-llama/Llama-2-7b-chat-hf"  # Adjust this to your specific Llama 2 model
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float16, device_map="auto")

    class GenerationRequest(BaseModel):
        prompt: str
        max_length: int = 100
        temperature: float = 0.7
        top_p: float = 0.9

    @app.post("/generate")
    async def generate_text(request: GenerationRequest):
        try:
            inputs = tokenizer(request.prompt, return_tensors="pt").to(model.device)
            
            outputs = model.generate(
                **inputs,
                max_length=request.max_length,
                temperature=request.temperature,
                top_p=request.top_p,
                do_sample=True
            )
            
            generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
            return {"generated_text": generated_text}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    @app.get("/")
    async def root():
        return {"message": "Llama 2 API is running"}

    if __name__ == "__main__":
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8080)
  '';
in
{
  # Llama 2 configuration
  environment.systemPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        torch
        transformers
        accelerate
        fastapi
        uvicorn
      ]
    ))
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  # CUDA configuration
  environment.variables = {
    CUDA_PATH = "${cudaPackages.cudatoolkit}";
    LD_LIBRARY_PATH = "${cudaPackages.cudatoolkit}/lib:${cudaPackages.cudnn}/lib";
  };

  # Create a systemd service for Llama 2
  systemd.services.llama2 = {
    description = "Llama 2 Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${llama2_api_script}";
      Restart = "on-failure";
      User = "geoffrey";
      WorkingDirectory = "/home/geoffrey";
    };
    environment = {
      PYTHONUNBUFFERED = "1";
    };
  };

  # Ensure the Llama 2 API script is in place
  system.activationScripts.llama2_api = ''
    mkdir -p /home/geoffrey
    cp ${llama2_api_script} /home/geoffrey/llama2_api.py
    chown geoffrey:users /home/geoffrey/llama2_api.py
    chmod 644 /home/geoffrey/llama2_api.py
  '';
}
