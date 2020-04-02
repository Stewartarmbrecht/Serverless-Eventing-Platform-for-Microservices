namespace ContentReactor.Audio.Services.Models
{
    using System;
    using Newtonsoft.Json;

    /// <summary>
    /// Stores a unique Id.
    /// </summary>
    public sealed class ModelIdentity
    {
        private ModelIdentity(Guid id) => this.Id = id;

        /// <summary>
        /// Gets the globally unique id.
        /// </summary>
        /// <value>Guid that is the id.</value>
        public Guid Id { get; private set; }

        /// <summary>
        /// Creates a new Id using the provided Guid.
        /// </summary>
        /// <param name="id">The Guid to use for the id.</param>
        /// <returns>A new instance of the ModelIdentity.</returns>
        public static ModelIdentity Create(Guid id) => new ModelIdentity(id);
    }
}
