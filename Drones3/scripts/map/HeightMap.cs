using Godot;

namespace Drones3.scripts.map
{
    public class HeightMap
    {
        private FastNoiseLite noise;
        private FastNoiseLite buildingNoise;
        private Vector2 widthOffset = new Vector2(100, 100);
        private Vector2 heightOffset = new Vector2(-100, -100);

        public HeightMap() 
        {
            noise = new FastNoiseLite();
            noise.Seed = 0;
        }

        public float GetHeight(Vector2 position)
        {
            var terrainHeight = noise.GetNoise2Dv(position) * 10;
            var buildingHeight = noise.GetNoise2Dv(position * 10f);
            var buildingWidth = noise.GetNoise2Dv(position * 10f + widthOffset);
            if (buildingHeight < 0.5f) 
            {
                buildingHeight = 0f;
            }
            else
            {
                buildingHeight -= 0.45f;
            }

            return terrainHeight + Mathf.RoundToInt(buildingHeight * 5f) * 10;
        }
    }
}
