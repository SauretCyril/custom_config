import requests
import base64
import time
import os
from PIL import Image
import io

def generate_textured_3d_model(
    image_path=None, 
    image_base64=None, 
    output_path="output_model.glb", 
    api_url="http://127.0.0.1:7960", 
    seed=1234,
    guidance_scale=5.0,
    num_inference_steps=20,
    octree_resolution=256,
    num_chunks=80,
    mesh_simplify_ratio=0.1
):
    """
    Génère un modèle 3D texturé à partir d'une image et l'exporte au format GLB.
    
    Args:
        image_path (str, optional): Chemin vers l'image à utiliser
        image_base64 (str, optional): Image encodée en base64
        output_path (str): Chemin où sauvegarder le modèle GLB généré
        api_url (str): URL de l'API Hunyuan3D (généralement http://127.0.0.1:7960)
        seed (int): Graine pour la génération (pour reproductibilité)
        guidance_scale (float): Échelle de guidage pour la génération (0-10)
        num_inference_steps (int): Nombre d'étapes d'inférence (1-50)
        octree_resolution (int): Résolution pour l'extraction du maillage (128-512)
        num_chunks (int): Nombre de chunks pour l'extraction du maillage (1-200)
        mesh_simplify_ratio (float): Ratio de simplification du maillage (0-1)
    
    Returns:
        str: Chemin vers le modèle GLB généré
    """
    try:
        # Préparer l'image en base64 si un chemin d'image est fourni
        if image_path and not image_base64:
            with open(image_path, "rb") as img_file:
                image_base64 = base64.b64encode(img_file.read()).decode('utf-8')
        
        if not image_base64:
            raise ValueError("Vous devez fournir soit image_path soit image_base64")
        
        # Configurer les paramètres de génération
        params = {
            'image_base64': image_base64,
            'seed': seed,
            'guidance_scale': guidance_scale,
            'num_inference_steps': num_inference_steps,
            'octree_resolution': octree_resolution,
            'num_chunks': num_chunks,
            'mesh_simplify_ratio': mesh_simplify_ratio,
            'apply_texture': True,  # Important: activer la texture
            'output_format': 'glb'
        }
        
        # Démarrer la génération
        print("Démarrage de la génération...")
        response = requests.post(f"{api_url}/generate_no_preview", data=params)
        response.raise_for_status()
        
        # Vérifier périodiquement l'état de la génération
        print("Génération en cours...")
        while True:
            status = requests.get(f"{api_url}/status").json()
            print(f"Progression: {status['progress']}% - {status['message']}")
            
            if status['status'] == 'COMPLETE':
                break
            elif status['status'] == 'FAILED':
                raise Exception(f"Échec de la génération: {status['message']}")
            
            time.sleep(2)  # Attendre 2 secondes avant de vérifier à nouveau
        
        # Télécharger le modèle
        print("Téléchargement du modèle...")
        response = requests.get(f"{api_url}/download/model")
        response.raise_for_status()
        
        # Sauvegarder le modèle
        with open(output_path, "wb") as f:
            f.write(response.content)
        
        print(f"Modèle sauvegardé sous {output_path}")
        return output_path
        
    except Exception as e:
        print(f"Erreur: {str(e)}")
        return None

# Exemple d'utilisation
if __name__ == "__main__":
    # Utiliser avec un chemin d'image
    generate_textured_3d_model(image_path="G:/Actions-11-Projects/P002/WorkingTemp/photo_10-05/voiture1.jpg")
    
    # Ou utiliser directement avec une image déjà encodée en base64
    # with open("image_encodee.txt", "r") as f:
    #     image_base64 = f.read()
    # generate_textured_3d_model(image_base64=image_base64)